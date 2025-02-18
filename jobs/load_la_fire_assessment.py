from __future__ import annotations

import random
import string
from typing import TYPE_CHECKING

import pandas
import requests

from jobs.utils.geo import gdf_from_esri_feature_service
from jobs.utils.snowflake import (
    gdf_to_snowflake,
    snowflake_connection_from_environment,
    table_exists,
)

if TYPE_CHECKING:
    import geopandas


datasets = [
    {
        "schema": "EPA_AGOL",
        "name": "PUBLIC_STATUS_ASSESSMENT",
        "url": (
            "https://services.arcgis.com/cJ9YHowT8TU7DUyn/ArcGIS/rest/services/"
            "SoCalFires2025_PublicStatusNightly/FeatureServer/0"
        ),
        "merge_on": ["OBJECTID", "_LOAD_DATE"]
    },
]

if __name__ == "__main__":
    for d in datasets:
        name = d["name"]
        url = d["url"]
        print(f"Loading {d['name']}")
        snowflake_conn = snowflake_connection_from_environment(schema=d["schema"])
        try:
            snowflake_conn.cursor().execute(
                f'CREATE SCHEMA IF NOT EXISTS "{snowflake_conn.schema}"'.upper()
            )

            # Last edit information lives in the JSON metadata
            metadata = requests.get(url + "?f=pjson").json()

            # Add a load date column, as we will be re-loading the dataset daily
            gdf: geopandas.GeoDataFrame = gdf_from_esri_feature_service(url).assign(
                _LOAD_DATE=pandas.Timestamp.today(tz="America/Los_Angeles").date(),
                _LAST_EDIT_DATE=metadata.get("editingInfo", {}).get("lastEditDate"),
            )  # type: ignore

            # Load to Snowflake
            if not table_exists(snowflake_conn, name):
                gdf_to_snowflake(gdf, snowflake_conn, name)
            else:
                # Create the initial table as a tmp table with a random suffix.
                # We will merge it with the target table to avoid duplicates and drop
                # the tmp table at the end
                tmp = (
                    name
                    + "_TMP_"
                    + "".join(random.choices(string.ascii_uppercase, k=3))
                )
                gdf_to_snowflake(gdf, snowflake_conn, tmp)

                # Merge the tmp table into the main one. It's not 100% clear
                # that ObjectID will *always* be stable, but for now it seems
                # like a good thing to merge on. If this seems problematic,
                # we can investigate APN (which is nullable). GlobalID does not seem
                # to be stable.
                non_merge_cols = set(gdf.columns) - set(d["merge_on"])
                merge_on = "and ".join(
                    [f'''{name}."{k}" = {tmp}."{k}"''' for k in d["merge_on"]]
                )
                when_matched = ",\n".join(
                    [f'''{name}."{k}" = {tmp}."{k}"''' for k in non_merge_cols]
                )
                when_not_matched_insert = ",\n".join(
                    [f'''"{k}"''' for k in non_merge_cols]
                )
                when_not_matched_values = ",\n".join(
                    [f'''{tmp}."{k}"''' for k in non_merge_cols]
                )
                snowflake_conn.cursor().execute(
                    f"""
                    merge into {name} using {tmp}
                        on {merge_on}
                    when matched then update set
                        {when_matched}
                    when not matched then insert
                        (
                            {when_not_matched_insert}
                        )
                        values
                        (
                            {when_not_matched_values}
                        )
                    """
                )

                # Clean up after ourselves
                snowflake_conn.cursor().execute(f"""drop table {tmp}""")
        finally:
                snowflake_conn.close()

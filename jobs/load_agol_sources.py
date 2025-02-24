from __future__ import annotations

import random
import string
from typing import TYPE_CHECKING, Any

import pandas

from jobs.utils.geo import gdf_from_esri_feature_service, get_with_backoff
from jobs.utils.snowflake import (
    gdf_to_snowflake,
    snowflake_connection_from_environment,
    table_exists,
)

if TYPE_CHECKING:
    import geopandas


datasets: list[dict[str, Any]] = [
    {
        "schema": "EPA_AGOL_ASSESSMENT",
        "name": "PUBLIC_STATUS_ASSESSMENT",
        "url": (
            "https://services.arcgis.com/cJ9YHowT8TU7DUyn/ArcGIS/rest/services/"
            "SoCalFires2025_PublicStatusNightly/FeatureServer/0"
        ),
        "merge_on": ["OBJECTID", "_LOAD_DATE"],
    },
    {
        "schema": "USACE_AGOL_DEBRIS",
        "name": "PARCEL_DEBRIS_REMOVAL",
        "url": (
            "https://jecop-public.usace.army.mil/arcgis/rest/services/"
            "USACE_Debris_Parcels_Southern_California_Public/MapServer/0"
        ),
        "merge_on": ["OBJECTID", "_LOAD_DATE"],
        # The USACE seems to have some bad SSL settings on their public-facing AGOL.
        # A bit concerning...
        "verify": False,
    },
]

if __name__ == "__main__":
    for d in datasets:
        name: str = d["name"]
        url: str = d["url"]
        verify = d.get("verify", True)
        print(f"Loading {d['name']}")
        snowflake_conn = snowflake_connection_from_environment(schema=d["schema"])
        try:
            snowflake_conn.cursor().execute(
                f'CREATE SCHEMA IF NOT EXISTS "{snowflake_conn.schema}"'.upper()
            )

            # Last edit information lives in the JSON metadata
            metadata = get_with_backoff(url + "?f=pjson", verify=verify).json()
            last_edit_date = metadata.get("editingInfo", {}).get("lastEditDate")

            # Add a load date column, as we will be re-loading the dataset daily
            gdf: geopandas.GeoDataFrame = (
                gdf_from_esri_feature_service(url, verify=verify).assign(
                    _LOAD_DATE=pandas.Timestamp.today(tz="America/Los_Angeles").date(),
                )  # type: ignore
            )
            if last_edit_date:
                gdf = gdf.assign(_LAST_EDIT_DATE=last_edit_date)  # type: ignore
            else:
                gdf = gdf.assign(_LOADED_AT=pandas.Timestamp.now(tz="UTC"))  # type: ignore

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
                    [f'''"{k}"''' for k in gdf.columns]
                )
                when_not_matched_values = ",\n".join(
                    [f'''{tmp}."{k}"''' for k in gdf.columns]
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
        except Exception as e:
            print(f"Unable to load {name}, due to {e}")
        finally:
            snowflake_conn.close()

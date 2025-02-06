from __future__ import annotations

import random
import string
from typing import TYPE_CHECKING

import pandas

from jobs.utils.geo import gdf_from_esri_feature_service
from jobs.utils.snowflake import (
    gdf_to_snowflake,
    snowflake_connection_from_environment,
    table_exists,
)

if TYPE_CHECKING:
    import geopandas


SCHEMA = "DDRC"
FEATURE_SERVICES = {
    "PUBLIC_STATUS_ASSESSMENT": (
        "https://services.arcgis.com/cJ9YHowT8TU7DUyn/ArcGIS/rest/services/"
        "SoCalFires2025_PublicStatusNightly/FeatureServer/0"
    )
}

if __name__ == "__main__":
    snowflake_conn = snowflake_connection_from_environment(schema=SCHEMA)
    snowflake_conn.cursor().execute(
        f'CREATE SCHEMA IF NOT EXISTS "{snowflake_conn.schema}"'.upper()
    )

    try:
        for name, url in FEATURE_SERVICES.items():
            print(f"Loading {name}")

            # Add a load date column, as we will be re-loading the dataset daily
            gdf: geopandas.GeoDataFrame = gdf_from_esri_feature_service(url).assign(
                _LOAD_DATE=pandas.Timestamp.today(tz="America/Los_Angeles").date()
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
                snowflake_conn.cursor().execute(
                    f"""
                    merge into {name} using {tmp}
                        on {name}."OBJECTID" = {tmp}."OBJECTID"
                        and {name}._LOAD_DATE = {tmp}._LOAD_DATE
                    when matched then update set
                        {name}."APN" = {tmp}."APN",
                        {name}."Address" = {tmp}."Address",
                        {name}."AssessmentDate" = {tmp}."AssessmentDate",
                        {name}."FireName" = {tmp}."FireName",
                        {name}."GlobalID" = {tmp}."GlobalID",
                        {name}."LandUse" = {tmp}."LandUse",
                        {name}."PublicStatus" = {tmp}."PublicStatus",
                        {name}."Shape__Area" = {tmp}."Shape__Area",
                        {name}."Shape__Length" = {tmp}."Shape__Length",
                        {name}."geometry" = {tmp}."geometry"
                    when not matched then insert
                        (
                            "APN",
                            "Address",
                            "AssessmentDate",
                            "FireName",
                            "GlobalID",
                            "LandUse",
                            "OBJECTID",
                            "PublicStatus",
                            "Shape__Area",
                            "Shape__Length",
                            "_LOAD_DATE",
                            "geometry"
                        )
                        values
                        (
                            {tmp}."APN",
                            {tmp}."Address",
                            {tmp}."AssessmentDate",
                            {tmp}."FireName",
                            {tmp}."GlobalID",
                            {tmp}."LandUse",
                            {tmp}."OBJECTID",
                            {tmp}."PublicStatus",
                            {tmp}."Shape__Area",
                            {tmp}."Shape__Length",
                            {tmp}."_LOAD_DATE",
                            {tmp}."geometry"
                        )
                    """
                )

                # Clean up after ourselves
                snowflake_conn.cursor().execute(f"""drop table {tmp}""")

    finally:
        snowflake_conn.close()

import requests
import pandas
from jobs.utils.snowflake import snowflake_connection_from_environment, table_exists

from snowflake.connector.pandas_tools import write_pandas


# The Malibu Rebuilds dashboard is built on JSON list responses from the following:
endpoints = {
    "PALISADES_PERMITS_ISSUED_READ": (
        "https://mlb-pptsrv.ci.malibu.ca.us/Home/PalisadesPermitsIssued_Read"
    ),
    "OVERALL_REBUILD_STATS_PIE_READ": (
        "https://mlb-pptsrv.ci.malibu.ca.us/Home/OverallRebuildStatsPie_Read?"
        "sFireView=PalisadesRebuildStatsDetailWithBPComplete"
    ),
    "FIRE_REBUILD_VISIT_POINTS": (
        "https://mlb-pptsrv.ci.malibu.ca.us/Home/FireRebuildVisitPoints"
    ),
    "FIRE_REBUILD_POINTS": (
        "https://mlb-pptsrv.ci.malibu.ca.us/Home/FireRebuildPoints/?s"
        "FireView=vPalisadesRebuildStatsDetailWithTimes"
    ),
}

if __name__ == "__main__":
    error_message = ""
    snowflake_conn = snowflake_connection_from_environment(schema="MALIBU_REBUILDS")

    for name, endpoint in endpoints.items():
        try:
            print(f"Loading {name}")
            # Fetch the data
            r = requests.get(endpoint)
            r.raise_for_status()

            # Include the load date so we can keep a history of the metrics by date
            load_date = pandas.Timestamp.today(tz="America/Los_Angeles").date()
            loaded_at = pandas.Timestamp.utcnow()
            df = pandas.DataFrame.from_records(r.json()).assign(
                _LOAD_DATE=load_date,
                _LOADED_AT=loaded_at,
            )

            if not table_exists(snowflake_conn, name):
                write_pandas(
                    snowflake_conn,
                    df,
                    name,
                    auto_create_table=True,
                    overwrite=True,
                    use_logical_type=True,
                )
            else:
                # If we have already loaded data for today, delete it before reloading.
                snowflake_conn.cursor().execute(
                    f"""delete from "{name}" where """
                    f"""_load_date = '{load_date.isoformat()}'"""
                )
                write_pandas(
                    snowflake_conn,
                    df,
                    name,
                    auto_create_table=False,
                    overwrite=False,
                    use_logical_type=True,
                )

        except Exception as e:
            print(f"Unable to load {name}, due to {e}")
            error_message += f"Unable to load {name}, due to {e} \n"

    if error_message:
        raise RuntimeError(error_message)

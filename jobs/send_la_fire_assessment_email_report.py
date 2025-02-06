import os
from jobs.utils.snowflake import snowflake_connection_from_environment

if __name__ == "__main__":
    recipients = os.environ.get("FIRE_REPORT_RECIPIENTS", "")
    snowflake_conn = snowflake_connection_from_environment(
        database="raw_ddrc_prd",
        schema="public",
    )
    snowflake_conn.cursor().execute(
        f"""call email_fire_assessment_report('{recipients}')"""
    )

    snowflake_conn.close()

import json
import os

from snowflake import snowpark
from snowflake.snowpark import types


def email_fire_assessment_report(session: snowpark.Session, emails: str) -> str:
    job = session.sql(
        """
        select
            "FireName" as "Fire Name",
            "PublicStatus" as "Status",
            count(*) as "Count"
        from raw_ddrc_prd.epa.public_status_assessment
        where _load_date = (
          select max(_load_date) from raw_ddrc_prd.epa.public_status_assessment
        )
        group by "FireName", "PublicStatus"
        order by "FireName", "PublicStatus"
        """
    ).collect_nowait()
    df = job.to_df().to_pandas()

    email_data = "<br>".join([
        f"Total number of properties: {df.Count.sum()}",
        "Assessment status:",
        df.groupby("Status").Count.sum().reset_index().style.hide().to_html(),
        "Assessment status broken down by fire:",
        df.style.hide().to_html(),
    ])
    session.sql(
        f"""
        CALL SYSTEM$SEND_EMAIL(
            'default_email_integration',
            '{emails}',
            'LA Fire Assessment Report',
            '{email_data}',
            'text/html'
        )
        """
    ).collect()
    return "Success"


if __name__ == "__main__":
    from jobs.utils.snowflake import snowflake_connection_from_environment

    # Create the snowpark session
    conn = snowflake_connection_from_environment(
        database=os.environ["SNOWFLAKE_DATABASE"],
        schema="PUBLIC",
        # TODO: think more deeply about which roles get access to email integrations
        role="SYSADMIN",
    )
    session = snowpark.Session.builder.configs({"connection": conn}).create()

    # Ensure an internal stage exists for storing our stored procedure.
    _ = session.sql(
        f"""create stage if not exists {conn.database}.{conn.schema}.internal_sprocs"""
    ).collect()

    # Register the procedure!
    session.sproc.register(
        func=email_fire_assessment_report,
        name="email_fire_assessment_report",
        return_type=types.StringType(),
        input_types=[types.StringType()],
        packages=["snowflake-snowpark-python", "pandas", "jinja2"],
        replace=True,
        source_code_display=True,
        is_permanent=True,
        stage_location=f"@{conn.database}.{conn.schema}.internal_sprocs",
    )

    # This feels very fragile
    session.sql(
        """grant usage on procedure email_fire_assessment_report(varchar)
        to role loader_ddrc_prd"""
    ).collect()

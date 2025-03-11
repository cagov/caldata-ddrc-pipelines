# CalData Digital Disaster Recovery Center Data Pipelines

This repo contains data pipelines, analysis, and reporting for California's
Digital Disaster Recovery Center (DDRC) following 2025's Los Angeles area fires.

# Architecture

The data pipelines in this contain the following things:

1. Fivetran loaders for loading data from SaaS tools.
1. Custom Python scripts for loading data from places for which a Fivetran loader
    does not exist (in `jobs/`).
1. A dbt project for transforming the data into the final summary metrics
    which are used for reporting and analysis (in `transform`).
1. Logic for unloading summary metrics to the production Azure storage bucket
    that is used to serve data for the DDRC.
1. Terraform configuration for Snowflake architecture and external stages.
1. Scripts for analysis and streamlit dashboarding.

## Data pipeline incident response

In the event of a failure of the pipeline, we will follow these steps:

1. An automated slack message will be posted to the `#odi-la-fires-recovery-tracking` Slack channel.
1. Depending on time of day and day of week, the responder may be CalData staff or Analytica staff.
1. The responder(s) evaluate whether the incident resulted in bad data being pushed to prod
    (higher severity) or is data testing/integrity issue upstream (lower severity).
1. The responder(s) write up an issue in GitHub documenting what they have learned and a proposed fix.
    The response may include (but is not limiuted to):
    *  Reverting commits in GitHub
    * Reverting changes in Airtable
    * Triggering new Fivetran syncs and/or GitHub actions jobs
    * Contacting our friends at CDT for front-end changes (probably as a last resort)
1. Depending on the severity, follow-on work is prioritized appropriately.
    If the incident is a night or weekend, every effort should be made to defer major work
    until business hours. Ideally, only high-severity incidents (resulting in bad data or
    nonsense being shown on the website) result in non-business hour work.
1. Any escalation should go to Ian, Jason, or Matt before impacting other CalData staff
1. After the issue is resolved, we schedule a quick retro for the following week.
    Attendance for the retro would be optional depending on involvement/interest.

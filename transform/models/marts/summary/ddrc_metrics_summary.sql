{{
  config(
    materialized = "table"
  )
}}

with epa_count_phase1_complete as (
    select
        'cleanup_phase1_complete' as metric_name,
        sum(public_status_count) as metric_value,
        'count' as metric_type,
        'cleanups completed' as metric_unit_label,
        'Daily' as update_frequency, --acceptable values for this field are 'As needed', 'Daily', 'Weekly', or 'Monthly'
        last_updated
    from {{ ref('public_status_by_land_use_and_fire_name_counted') }}
    where
        public_status = 'Phase 1 Complete'
        and land_use = 'Residential'
    group by public_status, last_updated
),

usace_parcel_debris_metrics as (
    select
    metric_name,
    metric_value,
    'count' as metric_type,
    metric_unit_label,
    'Daily' as update_frequency,
    last_updated
    from {{ ref('usace__dashboard_metrics') }}
),

--As additional automated metrics (as in, metrics that are not
--manually entered into the airtable are added to the DDRC,
--union them together here:
pipeline_metrics as (
    select * from epa_count_phase1_complete
    union all
    select * from usace_parcel_debris_metrics

),

--The Airtable captures all metrics, including those
--entered manually,
--we will use it to add in any of the metrics
--that we do not have automated pipelines for yet:
airtable_metrics as (
    select
        metric_machine_name as metric_name,
        metric as metric_value,
        metric_type,
        metric_unit_label,
        update_frequency,
        last_updated
    from {{ ref('airtable__most_recent_metrics') }}
    where
        metric_name not in (select metric_name from pipeline_metrics)
),

ddrc_metrics as (
    select * from pipeline_metrics
    union all
    select * from airtable_metrics
)

select * from ddrc_metrics

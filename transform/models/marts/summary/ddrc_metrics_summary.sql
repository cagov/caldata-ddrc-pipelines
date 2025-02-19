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

-- As additional metrics are added to the DDRC, union them here:
ddrc_metrics as (
    select * from epa_count_phase1_complete
    -- union all
    --select * from acoe_metric
)

select * from ddrc_metrics

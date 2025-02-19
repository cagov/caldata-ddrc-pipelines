{{
  config(
    materialized = "table"
  )
}}

with epa_count_phase1_complete as (
    select
        'cleanup_phase1_complete' as metric_name,
        sum(PUBLIC_STATUS_COUNT) as metric_value,
        last_updated
    from {{ ref('public_status_by_land_use_and_fire_name_counted') }}
    where PUBLIC_STATUS = 'Phase 1 Complete'
    and LAND_USE = 'Residential'
    group by PUBLIC_STATUS, LAST_UPDATED
), 

-- As additional metrics are added to the DDRC, union them here:
ddrc_metrics as (
    select * from epa_count_phase1_complete
    -- union all
    --select * from acoe_metric 
)

select * from ddrc_metrics
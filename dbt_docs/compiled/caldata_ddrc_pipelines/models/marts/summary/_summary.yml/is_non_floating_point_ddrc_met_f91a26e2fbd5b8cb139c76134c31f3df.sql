

with validation as (

    select
        metric_type as metric_type,
        metric_value as non_floating_point_field

    from ANALYTICS_DDRC_PRD.summary.ddrc_metrics_summary

),

validation_errors as (

    select
        non_floating_point_field

    from validation
    -- if this is true, then non_floating_point_field contains decimals

    where MOD(non_floating_point_field,1) <> 0
    and metric_type  = 'count'

)

select *
from validation_errors


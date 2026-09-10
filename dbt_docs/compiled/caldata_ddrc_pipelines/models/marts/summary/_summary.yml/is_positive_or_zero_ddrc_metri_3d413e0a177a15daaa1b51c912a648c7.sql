

with validation as (

    select
        metric_type as metric_type,
        metric_value as positive_field

    from ANALYTICS_DDRC_PRD.summary.ddrc_metrics_summary

),

validation_errors as (

    select
        positive_field

    from validation
    -- if this is true, then positive_field is negative
    where positive_field < 0 and metric_type  = 'count'

)

select *
from validation_errors


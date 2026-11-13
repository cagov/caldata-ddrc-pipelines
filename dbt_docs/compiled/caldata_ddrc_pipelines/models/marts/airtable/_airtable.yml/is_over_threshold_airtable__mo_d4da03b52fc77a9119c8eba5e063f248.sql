

with validation as (

    select
        metric_machine_name as metric_column_name,
        metric as amount_field

    from ANALYTICS_DDRC_PRD.airtable.airtable__most_recent_metrics

),

validation_errors as (

    select
        amount_field

    from validation
    -- if this is true, amount is not over threshold.
    where amount_field < 50000 and metric_column_name  = 'people_helped_drc'

)

select *
from validation_errors


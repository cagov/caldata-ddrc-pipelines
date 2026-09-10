

with validation as (

    select
        metric_type as metric_type,
        metric as positive_field

    from ANALYTICS_DDRC_PRD.airtable.airtable__most_recent_metrics

),

validation_errors as (

    select
        positive_field

    from validation
    -- if this is true, then positive_field is negative
    where positive_field < 0 and metric_type  = 'dollars - millions'

)

select *
from validation_errors


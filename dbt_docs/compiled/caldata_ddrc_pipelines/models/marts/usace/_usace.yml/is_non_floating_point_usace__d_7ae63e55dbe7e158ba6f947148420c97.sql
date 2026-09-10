

with validation as (

    select
        metric_unit_label as metric_type,
        metric_value as non_floating_point_field

    from ANALYTICS_DDRC_PRD.usace.usace__dashboard_metrics

),

validation_errors as (

    select
        non_floating_point_field

    from validation
    -- if this is true, then non_floating_point_field contains decimals

    where MOD(non_floating_point_field,1) <> 0
    and metric_type  = 'TK'

)

select *
from validation_errors


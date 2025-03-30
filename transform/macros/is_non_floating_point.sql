{% test is_non_floating_point(model, column_name, metric_type, metric_target_type) %}

with validation as (

    select
        {{ metric_type }} as metric_type,
        {{ column_name }} as non_floating_point_field

    from {{ model }}

),

validation_errors as (

    select
        non_floating_point_field

    from validation
    -- if this is true, then non_floating_point_field contains decimals
    where MOD(non_floating_point_field,1) <> 0 and metric_type  = {{ metric_target_type }}

)

select *
from validation_errors

{% endtest %}
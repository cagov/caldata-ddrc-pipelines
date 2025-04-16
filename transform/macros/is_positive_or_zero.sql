{% test is_positive_or_zero(model, column_name, metric_type, metric_target_type) %}

with validation as (

    select
        {{ metric_type }} as metric_type,
        {{ column_name }} as positive_field

    from {{ model }}

),

validation_errors as (

    select
        positive_field

    from validation
    -- if this is true, then positive_field is negative
    where positive_field < 0 and metric_type  = '{{ metric_target_type }}'

)

select *
from validation_errors

{% endtest %}
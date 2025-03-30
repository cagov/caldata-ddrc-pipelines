{% test is_over_threshold(model, column_name, metric_column_name, metric_name, threshold_amount) %}

with validation as (

    select
        {{ metric_column_name }} as metric_column_name,
        {{ column_name }} as amount_field

    from {{ model }}

),

validation_errors as (

    select
        amount_field

    from validation
    -- if this is true, amount is not over threshold.
    where amount_field < {{ threshold_amount }} and metric_column_name  = {{ metric_name }}

)

select *
from validation_errors

{% endtest %}
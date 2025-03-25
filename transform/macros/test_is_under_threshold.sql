{% test is_under_threshold(model, column_name, threshold_amount) %}

with validation as (

    select
        {{ column_name }} as amount_field

    from {{ model }}

),

validation_errors as (

    select
        amount_field

    from validation
    -- if this is true, amount is not under threshold.
    where amount_field > {{ threshold_amount }}

)

select *
from validation_errors

{% endtest %}
{% test is_non_floating_point(model, column_name) %}

with validation as (

    select
        {{ column_name }} as non_floating_point_field

    from {{ model }}

),

validation_errors as (

    select
        non_floating_point_field

    from validation
    -- if this is true, then non_floating_point_field contains decimals
    where MOD(non_floating_point_field,1) <> 0

)

select *
from validation_errors

{% endtest %}
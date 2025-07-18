with pasadena_rebuild_applications_received as (
    select
        'pasadena_rebuild_applications_received' as metric_name,
        0 as metric_value
),

pasadena_rebuild_applications_in_review as (
    select
        'pasadena_rebuild_applications_in_review' as metric_name,
        0 as metric_value
),

pasadena_building_permits_issued as (
    select
        'pasadena_building_permits_issued' as metric_name,
        0 as metric_value
),

combined as (
    select * from pasadena_rebuild_applications_received
    union all
    select * from pasadena_rebuild_applications_in_review
    union all
    select * from pasadena_building_permits_issued
)

select
    combined.*,
    convert_timezone('UTC', current_timestamp) as last_updated
from combined

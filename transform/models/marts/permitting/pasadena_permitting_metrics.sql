with pasadena_permitting as (
    select * from {{ ref('int_pasadena__eaton_fire_rebuild_permits') }}
),

pasadena_rebuild_applications_received as (
    select
        'pasadena_rebuild_applications_received' as metric_name,
        count(*) as metric_value
    from pasadena_permitting
),

pasadena_rebuild_applications_in_review as (
    select
        'pasadena_rebuild_applications_in_review' as metric_name,
        count(*) as metric_value
    from pasadena_permitting
    where permit_status in ('In Review')
),

pasadena_building_permits_issued as (
    select
        'pasadena_building_permits_issued' as metric_name,
        count(*) as metric_value
    from pasadena_permitting
    where permit_status in ('Issued')
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
    (select max(p.last_updated) as last_updated from pasadena_permitting as p) as last_updated
from combined

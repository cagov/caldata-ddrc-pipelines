with applications as (
    select * from {{ ref("int_malibu__applications") }}
),

malibu_rebuild_applications_received as (
    select
        'malibu_rebuild_applications_received' as metric_name,
        count(*) as metric_value
    from applications
),

malibu_rebuild_applications_in_review as (
    select
        'malibu_rebuild_applications_in_review' as metric_name,
        count(*) as metric_value
    from applications
    where type in ('InPlanning', 'InBPC')
),

malibu_building_permits_issued as (
    select
        'malibu_building_permits_issued' as metric_name,
        count(*) as metric_value
    from applications
    where type in ('PermitIssued')
),

-- TODO: what building permits are in the permits issued table?
-- seems to be different from the pplications table.
/*malibu_building_permits_issued as (
    select
        'malibu_building_permits_issued' as metric_name,
        any_value(permits) as metric_value,
        any_value(last_updated) as last_updated
    from {{ ref("int_malibu__permits_issued") }}
    where type = 'Building'
),*/

combined as (
    select * from malibu_rebuild_applications_received
    union all
    select * from malibu_rebuild_applications_in_review
    union all
    select * from malibu_building_permits_issued
)

select
    combined.*,
    (select max(a.last_updated) as last_updated from applications as a) as last_updated
from combined

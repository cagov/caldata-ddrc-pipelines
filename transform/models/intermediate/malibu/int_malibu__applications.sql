with rebuild_points as (
    select * from {{ ref("stg_malibu__fire_rebuild_points") }}
)

select
    type,
    lat,
    lon,
    project_number,
    planning_approved,
    convert_timezone('UTC', last_updated) as last_updated
from rebuild_points
where _load_date = (select max(_load_date) from rebuild_points)

with rebuild_points as (
    select * from TRANSFORM_DDRC_PRD.malibu.stg_malibu__fire_rebuild_points
)

select
    type,
    lat,
    lon,
    project_number,
    planning_approved,
    convert_timezone('UTC', last_updated) as last_updated
from rebuild_points
where _load_date = (select max(r._load_date) from rebuild_points as r)
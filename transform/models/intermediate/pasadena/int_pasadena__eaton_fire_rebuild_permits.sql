with rebuild_permits as (
    select * from {{ ref("stg_pasadena__eaton_fire_rebuild_permits") }}
)

select
    permit_number,
    parcel_number,
    address,
    city,
    state,
    zipcode,
    permit_status,
    work_class,
    permit_type,
    description,
    council_district,
    convert_timezone('UTC', last_updated) as last_updated
from rebuild_permits
where _load_date = (select max(_load_date) from rebuild_permits)

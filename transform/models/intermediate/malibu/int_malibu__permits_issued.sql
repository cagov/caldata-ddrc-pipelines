with permits_issued as (
    select * from {{ ref("stg_malibu__palisades_permits_issued_read") }}
)

select
    type,
    permits,
    convert_timezone('UTC', last_updated) as last_updated
from permits_issued
where _load_date = (select max(_load_date) from permits_issued)

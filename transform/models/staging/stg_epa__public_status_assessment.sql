with psa as (

select

    "APN" as assessor_parcel_number,
    "Address" as address,
    "AssessmentDate" as assessment_date,
    "FireName" as fire_name,
    "GlobalID" as global_id,
    "LandUse" as land_use,
    "OBJECTID" as object_id,
    "PublicStatus" as public_status,
    "Shape__Area" as shape_area,
    "Shape__Length" as shape_length,
    "_LAST_EDIT_DATE" as last_edit_date,
    "_LOAD_DATE" as load_date,
    "geometry" as geometry

from {{ source('EPA','PUBLIC_STATUS_ASSESSMENT') }}

)

select * from psa

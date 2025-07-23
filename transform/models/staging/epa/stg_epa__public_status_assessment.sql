with psa as (

    select

        apn as assessor_parcel_number,
        "Address" as address,
        "AssessmentDate" as assessment_date,
        "FireName" as fire_name,
        "GlobalID" as global_id,
        "LandUse" as land_use,
        objectid as object_id,
        "PublicStatus" as public_status,
        "Shape__Area" as shape_area,
        "Shape__Length" as shape_length,
        TO_TIMESTAMP_TZ(_last_edit_date, 3) as last_updated,
        _load_date as load_date,
        "geometry" as geometry

    from {{ source('EPA','PUBLIC_STATUS_ASSESSMENT') }}

)

select * from psa

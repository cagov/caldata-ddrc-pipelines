with pdr as (

    select
        "ma" as ma,
        "apn" as assessor_parcel_number,
        "apn_coincident_list" as apn_conincident_list,
        "address" as address,
        "epa_status" as epa_status,
        "roe_status" as roe_status,
        "hsa_status" as hsa_status,
        "pcr_status" as pcr_status,
        "fso_pkg_returned" as fso_pkg_returned,
        OBJECTID as object_id,
        GDB_TO_DATE as gdb_to_date,
        GDB_FROM_DATE as gdb_from_date,
        "geometry" as geometry,
        _LOAD_DATE, 
        to_timestamp(_LOADED_AT) as last_updated

    from {{ source('USACE','PARCEL_DEBRIS_REMOVAL') }}

)

select * from pdr

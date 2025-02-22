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
        objectid as object_id,
        gdb_to_date,
        gdb_from_date,
        "geometry" as geometry,
        _load_date,
        to_timestamp(_loaded_at) as last_updated

    from {{ source('USACE','PARCEL_DEBRIS_REMOVAL') }}

)

select * from pdr

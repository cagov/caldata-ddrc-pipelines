with pdr as (

    select
        "ma" as ma,
        "apn" as assessor_parcel_number,
        "apn_coincident_list" as apn_conincident_list,
        "address" as address,
        "epa_status" as epa_status,
        "roe_status" as roe_status,
        to_timestamp_tz("roe_received"::int, 3) as roe_received,
        to_timestamp_tz("roe_approved"::int, 3) as roe_approved,
        to_timestamp_tz("roe_submitted"::int, 3) as roe_submitted,
        to_timestamp_tz("roe_withdrawn"::int, 3) as roe_withdrawn,
        "roe_details" as roe_details,
        "hsa_status" as hsa_status,
        to_timestamp_tz("hsa_report_received"::int, 3) as hsa_report_received,
        to_timestamp_tz("hsa_report_approved"::int, 3) as hsa_report_approved,
        "pcr_status" as pcr_status,
        to_timestamp_tz("pcr_received"::int, 3) as pcr_received,
        to_timestamp_tz("pcr_approved"::int, 3) as pcr_approved,
        to_timestamp_tz("pcr_delivery"::int, 3) as pcr_delivery,
        to_timestamp_tz("fso_pkg_returned"::int, 3) as fso_pkg_returned,
        to_timestamp_tz("fso_pkg_approved"::int, 3) as fso_pkg_approved,
        objectid as object_id,
        gdb_to_date,
        gdb_from_date,
        "geometry" as geometry,
        "event_sub_name" as event_sub_name,
        _load_date,
        to_timestamp_tz(_loaded_at) as last_updated

    from {{ source('USACE','PARCEL_DEBRIS_REMOVAL') }}

)

select * from pdr

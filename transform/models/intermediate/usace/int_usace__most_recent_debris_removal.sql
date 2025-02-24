with pdr as (

    select * from {{ ref('stg_usace__parcel_debris_removal') }}

),


most_recent_pdr_data as (

    select
        epa_status,
        roe_status,
        hsa_status,
        pcr_status,
        fso_pkg_returned,
        object_id,
        _load_date,
        last_updated

    from pdr
    where last_updated = (select max(last_updated) from pdr)

)

select * from most_recent_pdr_data

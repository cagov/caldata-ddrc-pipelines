with pdr as (
    select * from {{ ref('stg_usace__parcel_debris_removal') }}
),

most_recent_pdr_data as (

    select
        ma,
        epa_status,
        roe_status,
        roe_approved,
        roe_submitted,
        roe_details,
        hsa_status,
        pcr_status,
        fso_pkg_approved,
        object_id,
        event_sub_name,
        _load_date,
        convert_timezone('UTC', last_updated) as last_updated

    from pdr
    where last_updated = (select max(p.last_updated) from pdr as p)

)

select * from most_recent_pdr_data

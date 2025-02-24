with pdr as (

    select * from {{ ref('stg_usace__parcel_debris_removal') }}

),

most_recent_date as (
    select MAX(last_updated) as max_date
    from pdr
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
    inner join most_recent_date as md on pdr.last_updated = md.max_date

)

select * from most_recent_pdr_data
with psa as (

    select * from {{ ref('stg_epa__public_status_assessment') }}

),

most_recent_date as (
    select MAX(load_date) as max_date
    from psa
),

most_recent_psa_data as (

    select
        psa.public_status,
        psa.land_use,
        psa.fire_name,
        psa.last_updated

    from psa
    inner join most_recent_date as md on psa.load_date = md.max_date

)

select * from most_recent_psa_data

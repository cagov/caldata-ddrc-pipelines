with psa as (

    select * from {{ ref('stg_epa__public_status_assessment') }}

),

most_recent_date as (
    select MAX(load_date) as max_date
    from psa
),

most_recent_psa_data as (

    select
        public_status,
        land_use,
        fire_name,
        last_edit_date

    from psa
    inner join most_recent_date as md on load_date = md.max_date

)

select * from most_recent_psa_data

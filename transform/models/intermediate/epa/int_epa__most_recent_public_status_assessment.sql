with psa as (

    select * from {{ ref('stg_epa__public_status_assessment') }}

),

most_recent_psa_data as (

    select
        public_status,
        land_use,
        fire_name,
        convert_timezone('UTC', last_updated) as last_updated
    from psa
    where load_date = (select max(load_date) from psa)
)

select * from most_recent_psa_data

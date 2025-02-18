with most_recent_psa_data as (
    select * from {{ ref('int_epa__most_recent_public_status_assessment') }}
),

ps_by_land_use_and_fire_name_counted as (

select
    public_status,
    COUNT(public_status) as public_status_count,
    land_use,
    fire_name,
    last_edit_date

    from most_recent_psa_data
    group by public_status, land_use, fire_name, last_edit_date

)

select * from ps_by_land_use_and_fire_name_counted
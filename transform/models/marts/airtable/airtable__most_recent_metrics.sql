with air as (

    select * from {{ ref('stg_airtable__metrics') }}

),

-- select most recent version of each individual metric
max_modified as (
    select
        metric_machine_name,
        to_number(metric, 10, 2) as metric,
        metric_type,
        metric_unit_label,
        update_frequency,
        date_created,
        max(date_created)
            over (partition by metric_name) as last_updated
    from air
)

select * from max_modified
where date_created = last_updated

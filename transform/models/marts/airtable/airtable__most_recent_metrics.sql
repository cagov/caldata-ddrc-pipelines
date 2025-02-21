with air as (

    select * from {{ ref('stg_airtable__metrics') }}

),

-- select most recent version of each individual metric
max_modified as (
    select
        metric_machine_name,
        to_numeric(metric) as metric,
        metric_type,
        metric_unit_label,
        update_frequency,
        date_metric_modified,
        max(date_metric_modified)
            over (partition by metric_name) as last_updated
    from air
)

select * from max_modified
where date_metric_modified = last_updated

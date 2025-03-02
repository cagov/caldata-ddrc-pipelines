with air as (

    select * from {{ ref('stg_airtable__metrics') }}
    where metric is not null

),


-- select most recent version of each individual metric
max_modified as (
    select
        metric_machine_name,
        to_number(metric, 38, 2) as metric,
        metric_type,
        metric_unit_label,
        lower(update_frequency) as update_frequency,
        date_created,
        max(date_created)
            over (partition by metric_name) as last_updated
    from air
)

select
    metric_machine_name,
    metric,
    metric_type,
    metric_unit_label,
    update_frequency,
    date_created,
    last_updated
from max_modified
where date_created = last_updated
group by all

with usace as (

    select * from {{ ref('stg_usace__parcel_debris_removal') }}

),

roe_status as (
    select
        'roes accepted' as metric_name,
        'TK' as metric_unit_label,
        count(distinct object_id) as metric_value,
        last_updated
    from usace
    where
        (
            roe_status <> 'not_received'
            or hsa_status <> 'not_received'
            or hsa_status = 'not_received'
        )
        and
        roe_status in ('approved', 'submitted')
    group by all
),

in_queue as (
    select
        'in queue with contractors' as metric_name,
        'TK' as metric_unit_label,
        count(distinct object_id) as metric_value,
        last_updated
    from usace
    where
        (
            roe_status <> 'not_received'
            or hsa_status <> 'not_received'
            or hsa_status = 'not_received'
        )
        and
        roe_status in ('submitted')
    group by all

),

fso_return as (
    select
        'fso package returned' as metric_name,
        'TK' as metric_unit_label,
        count(distinct object_id) as metric_value,
        last_updated
    from usace
    where
        fso_pkg_returned is not null
    group by all
),

usace_dashboard_metrics as (

    select * from roe_status
    union all
    select * from in_queue
    union all
    select * from fso_return

)

select * from usace_dashboard_metrics

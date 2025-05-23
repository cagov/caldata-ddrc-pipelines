with usace as (

    select * from {{ ref('int_usace__most_recent_debris_removal') }}
    where
        event_sub_name in ('Eaton', 'Palisades')
        and ma = '4856DR-CA-COE-SPD-09'

),

roe_status as (
    select
        'phase2_roes_accepted' as metric_name,
        'TK' as metric_unit_label,
        count(distinct object_id) as metric_value,
        last_updated
    from usace
    where roe_approved is not null
    group by all
),

in_queue as (
    select
        'phase2_parcels_in_queue' as metric_name,
        'TK' as metric_unit_label,
        count(distinct object_id) as metric_value,
        last_updated
    from usace
    where roe_submitted is not null
    group by all

),

-- reinstating this metric per Matt's request 3/20
fso_return as (
    select
        'phase2_parcels_completed' as metric_name,
        'TK' as metric_unit_label,
        count(distinct object_id) as metric_value,
        last_updated
    from usace
    where fso_pkg_approved is not null
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

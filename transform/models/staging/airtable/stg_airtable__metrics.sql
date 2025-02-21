with air as (

    select
        id,
        _fivetran_synced,
        datetime_offset_number,
        date_created,
        as_of_label,
        datetime_offset_variable,
        date_metric_modified,
        metric,
        a.value::varchar as metric_type,
        b.value::varchar as as_of_time,
        c.value::varchar as metric_name,
        d.value::varchar as metric_unit_label,
        e.value::varchar as metric_title_for_interface,
        f.value::varchar as metric_machine_name,
        g.value::varchar as topic,
        h.value::varchar as update_frequency

    from {{ source('AIRTABLE','METRICS') }},
        lateral flatten(metrics.metric_type_from_metric_definition_) a,
        lateral flatten(metrics.as_of_time_from_metric_definition_) b,
        lateral flatten(metrics.metric_name_from_metric_definition_) c,
        lateral flatten(metrics.metric_unit_label_from_metric_definition_) d,
        lateral flatten(metrics.metric_title_for_interface) e,
        lateral flatten(metrics.metric_machine_name_from_metric_definition_) f,
        lateral flatten(metrics.topic_from_metric_definition_) g,
        lateral flatten(metrics.update_frequency_from_metric_definition_) h

)

select * from air

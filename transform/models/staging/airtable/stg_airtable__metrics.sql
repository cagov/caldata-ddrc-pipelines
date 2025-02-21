with air as (

    select
        m.id,
        m._fivetran_synced,
        m.datetime_offset_number,
        m.date_created,
        m.as_of_label,
        m.datetime_offset_variable,
        m.date_metric_modified,
        m.metric,
        a.value::varchar as metric_type,
        b.value::varchar as as_of_time,
        c.value::varchar as metric_name,
        d.value::varchar as metric_unit_label,
        e.value::varchar as metric_title_for_interface,
        f.value::varchar as metric_machine_name,
        g.value::varchar as topic,
        h.value::varchar as update_frequency

    from {{ source('AIRTABLE','METRICS') }} m,
        lateral flatten(metrics.metric_type_from_metric_definition_) as a,
        lateral flatten(metrics.as_of_time_from_metric_definition_) as b,
        lateral flatten(metrics.metric_name_from_metric_definition_) as c,
        lateral flatten(metrics.metric_unit_label_from_metric_definition_) as d,
        lateral flatten(metrics.metric_title_for_interface) as e,
        lateral flatten(metrics.metric_machine_name_from_metric_definition_) as f,
        lateral flatten(metrics.topic_from_metric_definition_) as g,
        lateral flatten(metrics.update_frequency_from_metric_definition_) as h

)

select * from air

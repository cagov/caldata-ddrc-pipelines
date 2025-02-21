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
        a.value::varchar AS metric_type,
        b.value::varchar AS as_of_time,
        c.value::varchar AS metric_name,
        d.value::varchar AS metric_unit_label,
        e.value::varchar AS metric_title_for_interface,
        f.value::varchar AS metric_machine_name,
        g.value::varchar AS topic,
        h.value::varchar AS update_frequency
    from metrics,
        lateral FLATTEN(metrics.metric_type_from_metric_definition_) a,
        lateral FLATTEN(metrics.as_of_time_from_metric_definition_) b,
        lateral FLATTEN(metrics.metric_name_from_metric_definition_) c,
        lateral FLATTEN(metrics.metric_unit_label_from_metric_definition_) d,
        lateral FLATTEN(metrics.metric_title_for_interface) e,
        lateral FLATTEN(metrics.metric_machine_name_from_metric_definition_) f,
        lateral FLATTEN(metrics.topic_from_metric_definition_) g,
        lateral FLATTEN(metrics.update_frequency_from_metric_definition_) h

    from {{ source('AIRTABLE','METRICS') }}

)

select * from air

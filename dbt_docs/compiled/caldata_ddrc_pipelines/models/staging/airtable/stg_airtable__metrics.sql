with air as (

    select
        metrics.id,
        metrics._fivetran_synced,
        metrics.datetime_offset_number,
        to_timestamp_tz(metrics.date_created) as date_created,
        metrics.as_of_label,
        metrics.datetime_offset_variable,
        to_timestamp_tz(metrics.date_metric_modified) as date_metric_modified,
        metrics.metric,
        a.value::varchar as metric_type,
        b.value::varchar as as_of_time,
        c.value::varchar as metric_name,
        d.value::varchar as metric_unit_label,
        e.value::varchar as metric_title_for_interface,
        f.value::varchar as metric_machine_name,
        g.value::varchar as topic,
        h.value::varchar as update_frequency

    from RAW_DDRC_PRD.ODI_AIRTABLE_LA_RECOVERY_METRICS_APPL6HFEE8UDLUC3G.METRICS as metrics,
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
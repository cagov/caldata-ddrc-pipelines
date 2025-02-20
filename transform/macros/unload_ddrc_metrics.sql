{% macro unload_ddrc_metrics() -%}
  {% if target.name == 'prd' %}
    {% set stage = '@ANALYTICS_DDRC_PRD.PUBLIC.AZURE_STAGE_DDRC' %}
  {% else %}
    {% set stage = '@ANALYTICS_DDRC_DEV.PUBLIC.MARTS' %}
  {% endif %}
  {% set file_key = 'ddrc-metrics.json' %}
  {% set tbl = ref('ddrc_metrics_summary') %}
  {% set url = stage ~ '/' ~ file_key %}
  {% set query %}
      copy into {{ url }}
      from (
        select array_agg(object_construct(*)) from {{ tbl }}
      )
      file_format = (type=json compression=none)
      single = true
      overwrite = true;
  {% endset %}
  {{ log('Unloading ' ~ tbl ~ ' to ' ~ url, info=true) }}
  {{ run_query(query) }}
{% endmacro %}

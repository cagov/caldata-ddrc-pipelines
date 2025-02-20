{% macro unload_ddrc_metrics() -%}
  {% if target.name == 'prd' %}
    {% set stage = '@ANALYTICS_DDRC_PRD.PUBLIC.AZURE_STAGE_DDRC' %}
  {% else %}
    {% set stage = '@ANALYTICS_DDRC_DEV.PUBLIC.MARTS' %}
  {% endif %}
  {% set key = 'ddrc-metrics.json' %}
  {% set url = stage ~ '/' ~ key %}
      copy into {{ url }}
      from (
        select array_agg(object_construct(*)) from {{ this }}
      )
      file_format = (type=json compression=none)
      single = true
      overwrite = true;
{% endmacro %}

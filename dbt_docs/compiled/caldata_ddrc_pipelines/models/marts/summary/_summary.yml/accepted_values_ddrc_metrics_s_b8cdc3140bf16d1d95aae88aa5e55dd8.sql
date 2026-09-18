
    
    

with all_values as (

    select
        update_frequency as value_field,
        count(*) as n_records

    from ANALYTICS_DDRC_PRD.summary.ddrc_metrics_summary
    group by update_frequency

)

select *
from all_values
where value_field not in (
    'as needed','daily','weekly','monthly','completed','content update'
)



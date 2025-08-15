
    
    

select
    metric_name as unique_field,
    count(*) as n_records

from ANALYTICS_DDRC_PRD.summary.ddrc_metrics_summary
where metric_name is not null
group by metric_name
having count(*) > 1



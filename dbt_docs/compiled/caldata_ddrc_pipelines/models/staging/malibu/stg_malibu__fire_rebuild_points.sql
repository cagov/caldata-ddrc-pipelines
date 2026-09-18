select
    "type" as type,
    "lat" as lat,
    "lng" as lon,
    "projectNumber" as project_number,
    "planningApproved" as planning_approved,
    _load_date,
    _loaded_at as last_updated
from RAW_DDRC_PRD.MALIBU_REBUILDS.FIRE_REBUILD_POINTS
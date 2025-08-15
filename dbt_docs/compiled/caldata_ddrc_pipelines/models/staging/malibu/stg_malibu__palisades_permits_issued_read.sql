select
    "PermitType" as type,
    "PalisadesPermits" as permits,
    _load_date,
    _loaded_at as last_updated
from RAW_DDRC_PRD.MALIBU_REBUILDS.PALISADES_PERMITS_ISSUED_READ
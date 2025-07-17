select
    "PermitType" as type,
    "PalisadesPermits" as permits,
    _load_date
from {{ source("MALIBU_REBUILDS", "PALISADES_PERMITS_ISSUED_READ") }}

select
    "ID" as id,
    "PMPERMITID" as pm_permit_id,
    "PERMIT_NUMBER" as permit_number,
    "PARCEL_NUMBER" as parcel_number,
    "ADDRESS" as address,
    "CITY" as city,
    "STATE" as state,
    "ZIPCODE" as zipcode,
    "PERMIT_STATUS" as permit_status,
    "WORK_CLASS" as work_class,
    "PERMIT_TYPE" as permit_type,
    "DESCRIPTION" as description,
    "COUNCIL_DISTRICT" as council_district,
    "_LOAD_DATE" as _load_date,
    to_timestamp("_LAST_EDIT_DATE", 3) as last_updated
from {{ source("PASADENA_AGOL", "EATON_FIRE_REBUILD_PERMITS") }}

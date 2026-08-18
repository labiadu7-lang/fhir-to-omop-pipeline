WITH unnested_entries AS (
    SELECT
        UNNEST(entry) AS entry,
    FROM {{ source('fhir', 'fhir_bundles')}}
),

care_site_info AS (
SELECT
    entry.resource.id AS organization_id,
    entry.resource.active AS organization_active,
    entry.resource.name AS organization_name,
    UNNEST(CAST(entry.resource.identifier AS JSON[])) AS identifier_value,
    UNNEST(CAST(entry.resource.type AS JSON[])) AS type_value,
    UNNEST(CAST(entry.resource.telecom AS JSON[])) AS telecom_value,
    UNNEST(CAST(entry.resource.address AS JSON[])) AS address_value
FROM unnested_entries
WHERE entry.resource.resourceType = 'Organization'
),

organization_values AS (
SELECT
    organization_id,
    organization_name,
    type_value -> 'coding' -> 0 ->> 'code' AS organization_type_code,
    type_value -> 'coding' -> 0 ->> 'display' AS organization_type_display,
    address_value -> 'line' ->> 0 AS address_line,
    address_value ->> 'city' AS city,
    address_value ->> 'state' AS state,
    address_value ->> 'postalCode' AS postal_code,
    address_value ->> 'country' AS country
FROM care_site_info
)

SELECT
    organization_id,
    organization_name,
    organization_type_code,
    organization_type_display,
    address_line,
    city,
    state,
    postal_code,
    country
FROM organization_values
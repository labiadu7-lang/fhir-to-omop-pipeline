WITH unnested_entries AS (
    SELECT
        UNNEST(entry) AS entry
    FROM {{ source('fhir', 'fhir_bundles')}}
),

care_site_info AS (
SELECT
    entry.resource.id AS organization_id,
    entry.resource.name AS organization_name,
    UNNEST(CAST(entry.resource.type AS JSON[])) AS type_value
FROM unnested_entries
WHERE entry.resource.resourceType = 'Organization'
),

organization_values AS (
SELECT DISTINCT
    organization_id,
    organization_name,
    type_value -> 'coding' -> 0 ->> 'code' AS organization_type_code,
    type_value -> 'coding' -> 0 ->> 'display' AS organization_type_display
FROM care_site_info
)

SELECT
    organization_id,
    REPLACE(organization_name, '"', '') AS organization_name,
    organization_type_code,
    organization_type_display
FROM organization_values
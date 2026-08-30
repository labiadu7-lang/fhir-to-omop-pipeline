WITH unnested_entries AS (
    SELECT
        UNNEST(
            CAST(
                json_extract(json_content, '$.entry')
                AS JSON[]
            )
        ) AS entry
    FROM {{ source('fhir', 'fhir_bundles') }}
),

care_site_info AS (
    SELECT
        REPLACE(CAST(entry.resource.id AS VARCHAR), '"', '') AS organization_id,
        CAST(entry.resource.name AS VARCHAR) AS organization_name,
        UNNEST(CAST(entry.resource.type AS JSON[])) AS type_value
    FROM unnested_entries
    WHERE CAST(entry.resource.resourceType AS VARCHAR) = '"Organization"'
),

organization_values AS (
    SELECT DISTINCT
        organization_id,
        organization_name,
        CAST(type_value -> 'coding' -> 0 ->> 'code' AS VARCHAR) AS organization_type_code,
        CAST(type_value -> 'coding' -> 0 ->> 'display' AS VARCHAR) AS organization_type_display
    FROM care_site_info
)

SELECT
    organization_id,
    REPLACE(organization_name, '"', '') AS organization_name,
    organization_type_code,
    organization_type_display
FROM organization_values
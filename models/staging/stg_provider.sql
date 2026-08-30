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

flattened_types AS (
    SELECT
        REPLACE(entry.resource.id, '"', '') AS provider_id,
        entry.resource.active AS provider_active,
        REPLACE(entry.resource.gender, '"', '') AS gender_source_value,
        UNNEST(CAST(entry.resource.identifier AS JSON[])) AS identifier_value,
        UNNEST(CAST(entry.resource.name AS JSON[])) AS name_value
    FROM unnested_entries
    WHERE entry.resource.resourceType = '"Practitioner"'
),

provider_values AS (
    SELECT
        provider_id,
        provider_active,
        gender_source_value,
        identifier_value ->> 'value' AS provider_source_value,
        identifier_value ->> 'value' AS npi,
        name_value ->> 'family' AS provider_family_name,
        name_value -> 'given' ->> 0 AS provider_given_name,
        name_value -> 'prefix' ->> 0 AS provider_prefix
    FROM flattened_types
)

SELECT DISTINCT
    provider_id,
    provider_active,
    gender_source_value,
    provider_source_value,
    npi,
    provider_family_name,
    provider_given_name,
    provider_prefix
FROM provider_values
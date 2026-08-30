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

visit_info AS (
    SELECT
        entry.resource.id AS encounter_id,
        REPLACE(entry.resource.subject.reference, 'urn:uuid:', '') AS patient_id,
        REPLACE(CAST(json_extract(entry.resource, '$.participant[0].individual.reference') AS VARCHAR), 'urn:uuid:', '') AS provider_id,
        REPLACE(entry.resource.serviceProvider.reference, 'urn:uuid:', '') AS care_site_id,
        CAST(entry.resource.period.start AS TIMESTAMP) AS encounter_start_datetime,
        CAST(entry.resource.period.end AS TIMESTAMP) AS encounter_end_datetime,
        REPLACE(entry.resource.class.code, '"', '') AS visit_source_value,
        UNNEST(CAST(entry.resource.type AS JSON[])) AS nested_resource
    FROM unnested_entries
    WHERE entry.resource.resourceType = '"Encounter"'
),

second_unnest AS (
    SELECT
        encounter_id,
        UNNEST(CAST(nested_resource.coding AS JSON[])) AS visit_code
    FROM visit_info
)

SELECT
    v.encounter_id,
    REPLACE(v.patient_id, '"', '') AS patient_id,
    REPLACE(v.provider_id, '"', '') AS provider_id,
    v.care_site_id,
    v.encounter_start_datetime,
    v.encounter_end_datetime,
    v.visit_source_value,
    s.visit_code ->> 'code' AS encounter_type_code,
    s.visit_code ->> 'display' AS encounter_type_display
FROM visit_info v
LEFT JOIN second_unnest s ON v.encounter_id = s.encounter_id
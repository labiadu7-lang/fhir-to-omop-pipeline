WITH unnested_entries AS (
    SELECT
        UNNEST(entry) AS entry
    FROM {{ source('fhir', 'fhir_bundles')}}
),

visit_info AS (
SELECT
    entry.resource.id AS encounter_id,
    REPLACE(entry.resource.subject.reference, 'urn:uuid:', '') AS patient_id,
    REPLACE(entry.resource.participant[1].individual.reference, 'urn:uuid:', '') AS provider_id,
    REPLACE(entry.resource.serviceProvider.reference, 'urn:uuid:', '') AS care_site_id,

    entry.resource.period.start::TIMESTAMP AS encounter_start_datetime,
    entry.resource.period.end::TIMESTAMP AS encounter_end_datetime,

    entry.resource.class.code AS visit_source_value,
    UNNEST(CAST(entry.resource.type AS JSON[])) as nested_resource
FROM unnested_entries
WHERE entry.resource.resourceType = 'Encounter'
),

second_unnest AS (
SELECT
    encounter_id,
    UNNEST(CAST(nested_resource.coding AS JSON[])) As visit_code
FROM visit_info
)
SELECT
    v.encounter_id,
    CAST(v.patient_id AS uuid) AS patient_id,
    CAST(v.provider_id AS uuid) AS provider_id,
    CAST(v.care_site_id AS uuid) AS care_site_id,
    v.encounter_start_datetime,
    v.encounter_end_datetime,
    v.visit_source_value,
    s.visit_code ->>'code' AS encounter_type_code,
    s.visit_code ->> 'display' AS encounter_type_display
FROM visit_info v
LEFT JOIN second_unnest s on v.encounter_id= s.encounter_id
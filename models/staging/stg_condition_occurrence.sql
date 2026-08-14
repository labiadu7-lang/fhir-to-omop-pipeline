WITH unnested_entries AS (
    SELECT
        UNNEST(entry) AS entry,
    FROM {{ source('fhir', 'fhir_bundles')}}
),


occurrence_stuff AS (
    SELECT
        entry.resource.id AS condition_id,
        REPLACE(entry.resource.subject.reference, 'urn:uuid:', '') AS patient_id,
        REPLACE(entry.resource.encounter.reference, 'urn:uuid:', '') AS encounter_id,

        entry.resource.recordedDate AS condition_start_time,
        UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS condition_value,

        UNNEST(CAST(entry.resource.clinicalStatus.coding AS JSON[])) AS clinical_status,
        UNNEST(CAST(entry.resource.verificationStatus.coding AS JSON[])) AS verification_status
FROM unnested_entries
WHERE entry.resource.resourceType = 'Condition'
)


SELECT
    condition_id,
    CAST(patient_id AS uuid) AS patient_id,
    CAST(encounter_id AS uuid) AS encounter_id,
    condition_start_time,
    condition_value ->>'code' AS condition_code,
    condition_value ->>'display' AS condition_display,
    clinical_status ->>'code' AS clinical_status,
    verification_status ->>'code' AS verification_status
FROM occurrence_stuff
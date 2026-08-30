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

occurrence_stuff AS (
    SELECT
        CAST(entry.resource.id AS VARCHAR) AS condition_id,
        REPLACE(CAST(entry.resource.subject.reference AS VARCHAR), 'urn:uuid:', '') AS patient_id,
        REPLACE(CAST(entry.resource.encounter.reference AS VARCHAR), 'urn:uuid:', '') AS encounter_id,
        CAST(entry.resource.recordedDate AS TIMESTAMP) AS condition_start_time,
        UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS condition_value,
        UNNEST(CAST(entry.resource.clinicalStatus.coding AS JSON[])) AS clinical_status,
        UNNEST(CAST(entry.resource.verificationStatus.coding AS JSON[])) AS verification_status
    FROM unnested_entries
    WHERE CAST(entry.resource.resourceType AS VARCHAR) = '"Condition"'
)

SELECT
    condition_id,
    patient_id,
    encounter_id,
    condition_start_time,
    CAST(condition_value ->> 'code' AS VARCHAR) AS condition_code,
    CAST(condition_value ->> 'display' AS VARCHAR) AS condition_display,
    CAST(clinical_status ->> 'code' AS VARCHAR) AS clinical_status,
    CAST(verification_status ->> 'code' AS VARCHAR) AS verification_status
FROM occurrence_stuff
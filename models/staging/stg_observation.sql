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

observation_stuff AS (
    SELECT
        CAST(entry.resource.id AS VARCHAR) AS observation_id,
        REPLACE(CAST(entry.resource.subject.reference AS VARCHAR), 'urn:uuid:', '') AS patient_id,
        REPLACE(CAST(entry.resource.encounter.reference AS VARCHAR), 'urn:uuid:', '') AS encounter_id,
        CAST(entry.resource.effectiveDateTime AS TIMESTAMP) AS observation_datetime,
        CAST(entry.resource.issued AS TIMESTAMP) AS issued_datetime,
        CAST(entry.resource.code.text AS VARCHAR) AS observation_text,
        UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS observation_value
    FROM unnested_entries
    WHERE CAST(entry.resource.resourceType AS VARCHAR) = '"Observation"'
),

parsed_observations AS (
    SELECT
        observation_id,
        REPLACE(patient_id, '"', '') AS patient_id,
        encounter_id,
        observation_datetime,
        issued_datetime,
        observation_text,
        CAST(observation_value ->> 'code' AS VARCHAR) AS observation_code,
        CAST(observation_value ->> 'display' AS VARCHAR) AS observation_display
    FROM observation_stuff
),

allergy_stuff AS (
    SELECT
        CAST(entry.resource.id AS VARCHAR) AS observation_id,
        REPLACE(CAST(entry.resource.patient.reference AS VARCHAR), 'urn:uuid:', '') AS patient_id,
        CAST(NULL AS VARCHAR) AS encounter_id,
        CAST(entry.resource.recordedDate AS TIMESTAMP) AS observation_datetime,
        CAST(entry.resource.recordedDate AS TIMESTAMP) AS issued_datetime,
        CAST(entry.resource.code.text AS VARCHAR) AS observation_text,
        UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS observation_value
    FROM unnested_entries
    WHERE CAST(entry.resource.resourceType AS VARCHAR) = '"AllergyIntolerance"'
),

parsed_allergies AS (
    SELECT
        observation_id,
        REPLACE(patient_id, '"', '') AS patient_id,
        encounter_id,
        observation_datetime,
        issued_datetime,
        observation_text,
        CAST(observation_value ->> 'code' AS VARCHAR) AS observation_code,
        CAST(observation_value ->> 'display' AS VARCHAR) AS observation_display
    FROM allergy_stuff
),

combined_observations AS (
    SELECT * FROM parsed_observations
    UNION ALL
    SELECT * FROM parsed_allergies
)

SELECT * FROM combined_observations
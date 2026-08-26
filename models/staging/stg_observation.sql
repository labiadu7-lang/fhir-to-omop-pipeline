WITH unnested_entries AS (
    SELECT UNNEST(entry) AS entry
    FROM {{ source('fhir', 'fhir_bundles')}}
),

observation_stuff AS (
    SELECT
        entry.resource.id AS observation_id,
        REPLACE(entry.resource.subject.reference, 'urn:uuid:', '') AS patient_id,
        REPLACE(entry.resource.encounter.reference, 'urn:uuid:', '') AS encounter_id,
        entry.resource.effectiveDateTime AS observation_datetime,
        entry.resource.issued AS issued_datetime,
        entry.resource.code.text AS observation_text,
        UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS observation_value
    FROM unnested_entries
    WHERE entry.resource.resourceType = 'Observation'
),

parsed_observations AS (
    SELECT
        observation_id,
        CAST(patient_id AS UUID) AS patient_id,
        CAST(encounter_id AS UUID) AS encounter_id,
        observation_datetime,
        issued_datetime,
        observation_text,
        observation_value ->> 'code' AS observation_code,
        observation_value ->> 'display' AS observation_display
    FROM observation_stuff
),


allergy_stuff AS (
    SELECT
        entry.resource.id AS observation_id,
        REPLACE(entry.resource.patient.reference, 'urn:uuid:', '') AS patient_id,
        CAST(NULL AS VARCHAR) AS encounter_id,
        entry.resource.recordedDate AS observation_datetime,
        entry.resource.recordedDate AS issued_datetime,
        entry.resource.code.text AS observation_text,
        UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS observation_value
    FROM unnested_entries
    WHERE entry.resource.resourceType = 'AllergyIntolerance'
),

parsed_allergies AS (
    SELECT
        observation_id,
        CAST(patient_id AS UUID) AS patient_id,
        encounter_id,
        observation_datetime,
        issued_datetime,
        observation_text,
        observation_value ->> 'code' AS observation_code,
        observation_value ->> 'display' AS observation_display
    FROM allergy_stuff
),


combined_observations AS (
    SELECT * FROM parsed_observations
    UNION ALL
    SELECT * FROM parsed_allergies
)

SELECT * FROM combined_observations

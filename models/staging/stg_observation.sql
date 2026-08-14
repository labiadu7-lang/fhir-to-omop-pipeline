WITH unnested_entries AS (
    SELECT
        UNNEST(entry) AS entry
    FROM {{ source('fhir', 'fhir_bundles')}}
),

observation_stuff AS (
    SELECT
        entry.resource.id AS observation_id,

        REPLACE(entry.resource.subject.reference,'urn:uuid:','') AS patient_id,
        REPLACE(entry.resource.encounter.reference,'urn:uuid:','') AS encounter_id,

        entry.resource.status AS observation_status,
        entry.resource.effectiveDateTime AS observation_datetime,
        entry.resource.issued AS issued_datetime,
        entry.resource.code.text AS observation_text,

        UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS observation_value
    FROM unnested_entries
    WHERE entry.resource.resourceType = 'Observation'
)

SELECT
    observation_id,
    CAST(patient_id AS UUID) AS patient_id,
    CAST(encounter_id AS UUID) AS encounter_id,
    observation_status,
    observation_datetime,
    issued_datetime,
    observation_text,
    observation_value ->> 'code' AS observation_code,
    observation_value ->> 'display' AS observation_display
FROM observation_stuff
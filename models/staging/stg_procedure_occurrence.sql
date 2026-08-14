WITH unnested_entries AS (
    SELECT
        UNNEST(entry) AS entry
    FROM {{ source('fhir', 'fhir_bundles')}}
),

procedure_stuff AS (
SELECT
    entry.resource.id AS procedure_id,
    REPLACE(entry.resource.subject.reference, 'urn:uuid:', '') AS patient_id,
    REPLACE(entry.resource.encounter.reference, 'urn:uuid:', '') AS encounter_id,

    entry.resource.performedPeriod.start AS procedure_start_date,
    entry.resource.performedPeriod.end AS procedure_end_date,
    UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS procedure_values
FROM unnested_entries
WHERE entry.resource.resourceType = 'Procedure'
)

SELECT
    procedure_id,
    CAST(patient_id AS uuid) AS patient_id,
    CAST(encounter_id AS uuid) AS encounter_id,
    procedure_start_date,
    procedure_end_date,
    procedure_values ->>'code' AS procedure_code,
    procedure_values ->>'display' AS procedure_display
FROM procedure_stuff
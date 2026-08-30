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

procedure_stuff AS (
    SELECT
        entry.resource.id AS procedure_id,
        REPLACE(entry.resource.subject.reference, 'urn:uuid:', '') AS patient_id,
        REPLACE(entry.resource.encounter.reference, 'urn:uuid:', '') AS encounter_id,
        entry.resource.performedPeriod.start AS procedure_start_date,
        entry.resource.performedPeriod.end AS procedure_end_date,
        UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS procedure_values
    FROM unnested_entries
    WHERE entry.resource.resourceType = '"Procedure"'
),

immunization_stuff AS (
    SELECT
        entry.resource.id AS procedure_id,
        REPLACE(entry.resource.patient.reference, 'urn:uuid:', '') AS patient_id,
        REPLACE(entry.resource.encounter.reference, 'urn:uuid:', '') AS encounter_id,
        entry.resource.occurrenceDateTime AS procedure_start_date,
        entry.resource.occurrenceDateTime AS procedure_end_date,
        UNNEST(CAST(entry.resource.vaccineCode.coding AS JSON[])) AS procedure_values
    FROM unnested_entries
    WHERE entry.resource.resourceType = '"Immunization"'
),

combined_procedures AS (
    SELECT * FROM procedure_stuff
    UNION ALL
    SELECT * FROM immunization_stuff
)

SELECT
    CAST(procedure_id AS VARCHAR) AS procedure_id,
    CAST(patient_id AS VARCHAR) AS patient_id,
    CAST(encounter_id AS VARCHAR) AS encounter_id,
    procedure_start_date,
    procedure_end_date,
    procedure_values ->> 'code' AS procedure_code,
    procedure_values ->> 'display' AS procedure_display
FROM combined_procedures
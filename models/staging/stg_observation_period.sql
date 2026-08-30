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

isolated_encounters AS (
    SELECT
        REPLACE(CAST(entry.resource.subject.reference AS VARCHAR), 'urn:uuid:', '') AS patient_id,
        CAST(entry.resource.period.start AS TIMESTAMP) AS encounter_start,
        CAST(entry.resource.period.end AS TIMESTAMP) AS encounter_end
    FROM unnested_entries
    WHERE CAST(entry.resource.resourceType AS VARCHAR) = '"Encounter"'
),

aggregated_periods AS (
    SELECT
        patient_id,
        MIN(encounter_start) AS first_clinical_date,
        MAX(encounter_end) AS last_clinical_date
    FROM isolated_encounters
    WHERE patient_id IS NOT NULL
    GROUP BY patient_id
)

SELECT
    REPLACE(patient_id, '"', '') AS patient_id,
    first_clinical_date,
    last_clinical_date
FROM aggregated_periods
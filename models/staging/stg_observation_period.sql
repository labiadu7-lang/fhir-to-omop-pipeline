WITH unnested_entries AS (
        SELECT
            UNNEST(entry) AS entry

        FROM {{ source('fhir', 'fhir_bundles')}}
    ),

    isolated_encounters AS (
        SELECT
            REPLACE(entry.resource.subject.reference, 'urn:uuid:', '') AS patient_id,
            CAST(entry.resource.period.start AS TIMESTAMP) AS encounter_start,
            CAST(entry.resource.period.end AS TIMESTAMP) AS encounter_end
        FROM unnested_entries
        WHERE entry.resource.resourceType = 'Encounter'
    ),
    aggregated_periods AS (
        SELECT
            patient_id,
            MIN(encounter_start) AS first_clinical_date,
            MAX(encounter_end) AS last_clinical_date
        FROM isolated_encounters
        GROUP BY patient_id
    )
    SELECT
        patient_id,
        first_clinical_date,
        last_clinical_date,
    FROM aggregated_periods
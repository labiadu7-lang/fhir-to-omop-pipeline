    WITH unnested_entries AS (
        SELECT
            UNNEST(entry) AS entry
        FROM {{ source('fhir', 'fhir_bundles')}}
    )
    SELECT
        entry.resource.id AS patient_id,
        entry.resource.gender AS gender,
        entry.resource.birthDate AS birth_date,
        entry.resource.deceasedDateTime AS death_date,

        entry.resource.extension[1].extension[1].valueCoding.display AS patient_race,
        entry.resource.extension[1].extension[1].valueCoding.code AS patient_race_code,
        entry.resource.extension[2].extension[1].valueCoding.display AS patient_ethnicity,
        entry.resource.extension[2].extension[1].valueCoding.code AS patient_ethnicity_code
    FROM unnested_entries
    WHERE entry.resource.resourceType = 'Patient'
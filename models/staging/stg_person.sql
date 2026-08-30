WITH unnested_entries AS (
    SELECT
        UNNEST(
            CAST(
                json_extract(json_content, '$.entry')
                AS JSON[]
            )
        ) AS entry
    FROM {{ source('fhir', 'fhir_bundles') }}
)
SELECT
    REPLACE(entry.resource.id, '"', '') AS patient_id,
    REPLACE(entry.resource.gender, '"', '') AS gender,
    entry.resource.birthDate AS birth_date,
    entry.resource.deceasedDateTime AS death_date,
    REPLACE(entry.resource.extension[0].extension[0].valueCoding.display, '"', '') AS patient_race,
    REPLACE(entry.resource.extension[0].extension[0].valueCoding.code, '"', '') AS patient_race_code,
    REPLACE(entry.resource.extension[1].extension[0].valueCoding.display, '"', '') AS patient_ethnicity,
    REPLACE(entry.resource.extension[1].extension[0].valueCoding.code, '"', '') AS patient_ethnicity_code
FROM unnested_entries
WHERE entry.resource.resourceType = '"Patient"'
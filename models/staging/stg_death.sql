WITH unnested_entries AS (
    SELECT
        UNNEST(entry) AS entry,
    FROM {{ source('fhir', 'fhir_bundles')}}
)
    SELECT
        entry.resource.id AS patient_id,
        entry.resource.deceasedDateTime AS death_date_time
    FROM unnested_entries
    WHERE entry.resource.resourceType = 'Patient'
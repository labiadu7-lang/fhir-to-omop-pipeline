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
    CAST(entry.resource.id AS VARCHAR) AS patient_id,
    CAST(entry.resource.deceasedDateTime AS TIMESTAMP) AS death_date_time
FROM unnested_entries
WHERE CAST(entry.resource.resourceType AS VARCHAR) = '"Patient"'
  AND entry.resource.deceasedDateTime IS NOT NULL
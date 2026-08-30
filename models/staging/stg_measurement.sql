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

measurement_stuff AS (
    SELECT
        CAST(entry.resource.id AS VARCHAR) AS measurement_id,
        REPLACE(CAST(entry.resource.subject.reference AS VARCHAR), 'urn:uuid:', '') AS patient_id,
        REPLACE(CAST(entry.resource.encounter.reference AS VARCHAR), 'urn:uuid:', '') AS encounter_id,
        CAST(entry.resource.status AS VARCHAR) AS measurement_status,
        CAST(entry.resource.effectiveDateTime AS TIMESTAMP) AS measurement_datetime,
        CAST(entry.resource.issued AS TIMESTAMP) AS issued_datetime,
        CAST(entry.resource.code.text AS VARCHAR) AS measurement_text,
        UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS measurement_value,
        CAST(entry.resource.valueQuantity.value AS DOUBLE) AS value_as_number,
        CAST(entry.resource.valueQuantity.unit AS VARCHAR) AS unit,
        CAST(entry.resource.valueQuantity.system AS VARCHAR) AS unit_system,
        CAST(entry.resource.valueQuantity.code AS VARCHAR) AS unit_code,
        UNNEST(CAST(entry.resource.component AS JSON[])) AS component_value,
        CAST(entry.resource.valueCodeableConcept AS JSON) AS value_codeable_concept
    FROM unnested_entries
    WHERE CAST(entry.resource.resourceType AS VARCHAR) = '"Observation"'
)

SELECT
    measurement_id,
    REPLACE(patient_id, '"', '') AS patient_id,
    encounter_id,
    measurement_status,
    measurement_datetime,
    issued_datetime,
    CASE
        WHEN component_value IS NOT NULL
        THEN CAST(component_value -> 'code' -> 'coding' -> 0 ->> 'code' AS VARCHAR)
        ELSE CAST(measurement_value ->> 'code' AS VARCHAR)
    END AS measurement_code,
    CASE
        WHEN component_value IS NOT NULL
        THEN CAST(component_value -> 'code' -> 'coding' -> 0 ->> 'display' AS VARCHAR)
        ELSE CAST(measurement_value ->> 'display' AS VARCHAR)
    END AS measurement_display,
    CASE
        WHEN component_value IS NOT NULL
        THEN CAST(component_value -> 'valueQuantity' ->> 'value' AS VARCHAR)
        WHEN value_codeable_concept IS NOT NULL
        THEN CAST(value_codeable_concept ->> 'text' AS VARCHAR)
        ELSE CAST(value_as_number AS VARCHAR)
    END AS value,
    CASE
        WHEN component_value IS NOT NULL
        THEN CAST(component_value -> 'valueQuantity' ->> 'unit' AS VARCHAR)
        ELSE unit
    END AS unit,
    CASE
        WHEN component_value IS NOT NULL
        THEN CAST(component_value -> 'valueQuantity' ->> 'code' AS VARCHAR)
        ELSE unit_code
    END AS unit_code
FROM measurement_stuff
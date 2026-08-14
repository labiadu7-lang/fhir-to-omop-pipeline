WITH unnested_entries AS (
    SELECT
        UNNEST(entry) AS entry,
    FROM {{ source('fhir', 'fhir_bundles')}}
),

measurement_stuff AS (
    SELECT
        entry.resource.id AS measurement_id,

        REPLACE(entry.resource.subject.reference,'urn:uuid:','') AS patient_id,
        REPLACE(entry.resource.encounter.reference,'urn:uuid:','') AS encounter_id,

        entry.resource.status AS measurement_status,
        entry.resource.effectiveDateTime AS measurement_datetime,
        entry.resource.issued AS issued_datetime,
        entry.resource.code.text AS measurement_text,

        UNNEST(CAST(entry.resource.code.coding AS JSON[])) AS measurement_value,

        entry.resource.valueQuantity.value AS value_as_number,
        entry.resource.valueQuantity.unit AS unit,
        entry.resource.valueQuantity.system AS unit_system,
        entry.resource.valueQuantity.code AS unit_code,

        UNNEST(CAST(entry.resource.component AS JSON[])) AS component_value,
        entry.resource.valueCodeableConcept AS value_codeable_concept

    FROM unnested_entries
    WHERE entry.resource.resourceType = 'Observation'
)

SELECT
    measurement_id,
    CAST(patient_id AS UUID) AS patient_id,
    CAST(encounter_id AS UUID) AS encounter_id,
    measurement_status,
    measurement_datetime,
    issued_datetime,

    CASE
        WHEN component_value IS NOT NULL
        THEN component_value -> 'code' -> 'coding' -> 0 ->> 'code'
        ELSE measurement_value ->> 'code'
    END AS measurement_code,

    CASE
        WHEN component_value IS NOT NULL
        THEN component_value -> 'code' -> 'coding' -> 0 ->> 'display'
        ELSE measurement_value ->> 'display'
    END AS measurement_display,

    CASE
        WHEN component_value IS NOT NULL
        THEN CAST(component_value -> 'valueQuantity' ->> 'value'AS VARCHAR)

        WHEN value_codeable_concept IS NOT NULL
        THEN value_codeable_concept ->> 'text'

        ELSE CAST(value_as_number AS VARCHAR)
    END AS value,

    CASE
        WHEN component_value IS NOT NULL
        THEN component_value -> 'valueQuantity' ->> 'unit'

        ELSE unit
    END AS unit,


    CASE
        WHEN component_value IS NOT NULL
        THEN component_value -> 'valueQuantity' ->> 'code'

        ELSE unit_code
    END AS unit_code

FROM measurement_stuff
SELECT
    ROW_NUMBER() OVER (ORDER BY measurement_id) AS measurement_id,
    patient_id,
    encounter_id,
    CAST(NULL AS INTEGER) AS person_id,
    CAST(NULL AS INTEGER) AS visit_occurrence_id,
    CAST(0 AS INTEGER) AS measurement_concept_id,
    CAST(measurement_datetime AS DATE) AS measurement_date,
    measurement_datetime AS measurement_datetime,
    CAST(issued_datetime AS TIME) AS measurement_time,
    CAST(0 AS INTEGER) AS measurement_type_concept_id,
    CAST(0 AS INTEGER) AS operator_concept_id,

    CASE
        WHEN TRY_CAST(value AS DOUBLE) IS NOT NULL THEN CAST(value AS DOUBLE)
        ELSE NULL
    END AS value_as_number,

    CAST(0 AS INTEGER) AS value_as_concept_id,
    CAST(0 AS INTEGER) AS unit_concept_id,
    CAST(NULL AS DOUBLE) AS range_low,
    CAST(NULL AS DOUBLE) AS range_high,
    CAST(NULL AS INTEGER) AS provider_id,
    CAST(NULL AS INTEGER) AS visit_detail_id,
    CAST(measurement_code AS VARCHAR(50)) AS measurement_source_value,
    CAST(0 AS INTEGER) AS measurement_source_concept_id,
    CAST(unit AS VARCHAR(50)) AS unit_source_value,
    CAST(0 AS INTEGER) AS unit_source_concept_id,

    CASE
        WHEN TRY_CAST(value AS DOUBLE) IS NULL THEN CAST(value AS VARCHAR(50))
        ELSE NULL
    END AS value_source_value,

    CAST(NULL AS INTEGER) AS measurement_event_id,
    CAST(0 AS INTEGER) AS meas_event_field_concept_id
FROM {{ ref('stg_measurement') }}
ORDER BY measurement_id

SELECT
    ROW_NUMBER() OVER (ORDER BY device_id) AS device_exposure_id,
    patient_id,
    CAST(NULL AS INTEGER) AS person_id,
    CAST(0 AS INTEGER) AS device_concept_id,
    CAST(manufacture_datetime AS DATE) AS device_exposure_start_date,
    manufacture_datetime AS device_exposure_start_datetime,
    CAST(expiration_datetime AS DATE) AS device_exposure_end_date,
    expiration_datetime AS device_exposure_end_datetime,
    CAST(0 AS INTEGER) AS device_type_concept_id,
    CAST(device_udi AS VARCHAR(255)) AS unique_device_id,
    CAST(NULL AS VARCHAR(255)) AS production_id,
    CAST(1 AS INTEGER) AS quantity,
    CAST(NULL AS INTEGER) AS provider_id,
    CAST(NULL AS INTEGER) AS visit_occurrence_id,
    CAST(NULL AS INTEGER) AS visit_detail_id,
    CAST(device_code AS VARCHAR(50)) AS device_source_value,
    CAST(0 AS INTEGER) AS device_source_concept_id,
    CAST(NULL AS INTEGER) AS unit_concept_id,
    CAST(NULL AS VARCHAR(50)) AS unit_source_value,
    CAST(0 AS INTEGER) AS unit_source_concept_id
FROM {{ ref('stg_device') }}
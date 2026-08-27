
SELECT

    ROW_NUMBER() OVER (ORDER BY condition_id) AS condition_occurrence_id,
    patient_id,
    encounter_id,

    CAST(NULL AS INTEGER) AS person_id,
    CAST(0 AS INTEGER) AS condition_concept_id,


    CAST(condition_start_time AS DATE) AS condition_start_date,
    CAST(condition_start_time AS TIMESTAMP) AS condition_start_datetime,
    CAST(NULL AS DATE) AS condition_end_date,
    CAST(NULL AS TIMESTAMP) AS condition_end_datetime,


    CAST(0 AS INTEGER) AS condition_type_concept_id,
    CAST(0 AS INTEGER) AS condition_status_concept_id,

    CAST(NULL AS VARCHAR(20)) AS stop_reason,
    CAST(NULL AS INTEGER) AS provider_id,
    CAST(NULL AS INTEGER) AS visit_occurrence_id,
    CAST(0 AS INTEGER) AS visit_detail_id,


    CAST(condition_code AS VARCHAR(50)) AS condition_source_value,
    CAST(0 AS INTEGER) AS condition_source_concept_id,
    CAST(clinical_status AS VARCHAR(50)) AS condition_status_source_value

FROM {{ ref('stg_condition_occurrence') }}
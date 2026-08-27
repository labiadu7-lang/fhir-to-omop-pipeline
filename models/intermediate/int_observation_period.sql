SELECT
    ROW_NUMBER() OVER (ORDER BY patient_id) AS observation_period_id,
    CAST(NULL AS INTEGER) AS person_id,
    CAST(patient_id AS VARCHAR(50)) AS patient_id,
    CAST(first_clinical_date AS DATE) AS observation_period_start_date,
    CAST(last_clinical_date AS DATE) AS observation_period_end_date,
    CAST(0 AS INTEGER) AS period_type_concept_id
FROM {{ ref('stg_observation_period') }}
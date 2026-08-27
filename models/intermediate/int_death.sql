SELECT
    patient_id,
    CAST(NULL AS INTEGER) AS person_id,
    CAST(death_date_time AS DATE) AS death_date,
    CAST(death_date_time AS TIMESTAMP) AS death_datetime,
    CAST(0 AS INTEGER) AS death_type_concept_id,
    CAST(0 AS INTEGER) AS cause_concept_id,
    CAST(NULL AS VARCHAR(50)) AS cause_source_value,
    CAST(0 AS INTEGER) AS cause_source_concept_id
FROM {{ ref('stg_death') }}
WHERE death_date_time IS NOT NULL
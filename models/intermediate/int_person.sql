SELECT
    ROW_NUMBER() OVER (ORDER BY patient_id) AS person_id,

    CAST(NULL AS INTEGER) AS gender_concept_id,

    CAST(EXTRACT(YEAR FROM CAST(birth_date AS DATE)) AS INTEGER) AS year_of_birth,
    CAST(EXTRACT(MONTH FROM CAST(birth_date AS DATE)) AS INTEGER) AS month_of_birth,
    CAST(EXTRACT(DAY FROM CAST(birth_date AS DATE)) AS INTEGER) AS day_of_birth,
    CAST(birth_date AS TIMESTAMP) AS birth_datetime,

    CAST(NULL AS INTEGER) AS race_concept_id,
    CAST(NULL AS INTEGER) AS ethnicity_concept_id,

    CAST(NULL AS INTEGER) AS location_id,
    CAST(NULL AS INTEGER) AS provider_id,
    CAST(NULL AS INTEGER) AS care_site_id,

    CAST(patient_id AS VARCHAR(50)) AS person_source_value,

    CAST(gender AS VARCHAR(50)) AS gender_source_value,
    0 AS gender_source_concept_id,

    CAST(patient_race AS VARCHAR(50)) AS race_source_value,
    0 AS race_source_concept_id,

    CAST(patient_ethnicity AS VARCHAR(50)) AS ethnicity_source_value,
    0 AS ethnicity_source_concept_id

FROM {{ ref("stg_person") }}
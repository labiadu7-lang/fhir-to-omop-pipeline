WITH gender_concepts AS (
SELECT
    concept_id,
    concept_name
FROM {{ ref("concept_table") }}
WHERE domain_id = 'Gender' AND standard_concept = 'S'
),

race_concepts AS (
SELECT
    concept_id,
    concept_name
FROM {{ ref("concept_table") }}
WHERE domain_id = 'Race' AND standard_concept = 'S'
),

ethnicity_concepts AS (
SELECT
    concept_id,
    concept_name
FROM {{ ref("concept_table")}}
WHERE domain_id = 'Ethnicity' AND standard_concept = 'S'
    )

SELECT
    person_id,
    COALESCE(g.concept_id, 0) AS gender_concept_id,

    year_of_birth,
    month_of_birth,
    day_of_birth,
    birth_datetime,

    COALESCE(r.concept_id, 0) AS race_concept_id,
    COALESCE(e.concept_id, 0) AS ethnicity_concept_id,

    l.location_id,
    provider_id,
    care_site_id,

    person_source_value,

    gender_source_value,
    gender_source_concept_id,

    race_source_value,
    race_source_concept_id,

    ethnicity_source_value,
    ethnicity_source_concept_id
FROM {{ ref("int_person")}} p
LEFT JOIN gender_concepts g
    ON LOWER(p.gender_source_value) = LOWER(g.concept_name)
LEFT JOIN race_concepts r
    ON LOWER(TRIM(p.race_source_value)) = LOWER(TRIM(r.concept_name))
LEFT JOIN ethnicity_concepts e
    ON LOWER(p.ethnicity_source_value) = LOWER(e.concept_name)
LEFT JOIN {{ ref("int_location")}} l
    ON p.person_source_value = l.patient_id
ORDER BY person_id






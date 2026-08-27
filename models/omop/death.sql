SELECT
    p.person_id,
    death_date,
    death_datetime,
    COALESCE(death_type_concept_id, 0) AS death_type_concept_id,
    COALESCE(cause_concept_id, 0) AS cause_concept_id,
    cause_source_value,
    COALESCE(cause_source_concept_id, 0) AS cause_source_concept_id
FROM {{ ref('int_death') }} d
LEFT JOIN {{ ref("int_person")}} p
    ON d.patient_id = p.person_source_value
WHERE death_date IS NOT NULL
ORDER BY person_id
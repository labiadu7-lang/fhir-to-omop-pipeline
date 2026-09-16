SELECT
    p.person_id,
    death_date,
    death_datetime,
    32817 AS death_type_concept_id,
    NULL AS cause_concept_id,
    cause_source_value,
    NULL AS cause_source_concept_id
FROM {{ ref('int_death') }} d
LEFT JOIN {{ ref("int_person")}} p
    ON d.patient_id = p.person_source_value
WHERE death_date IS NOT NULL
ORDER BY person_id
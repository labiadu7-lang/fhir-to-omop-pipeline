SELECT DISTINCT
    observation_period_id,
    p.person_id,
    observation_period_start_date,
    observation_period_end_date,
    COALESCE(c.concept_id, 0) AS period_type_concept_id
FROM {{ ref("int_observation_period")}} op
LEFT JOIN {{ ref("int_person")}} p
    ON op.patient_id = p.person_source_value
LEFT JOIN {{ ref('CONCEPT') }} AS c
    ON c.concept_name = 'Standard algorithm from EHR'
    AND c.domain_id = 'Type Concept'
    AND c.standard_concept = 'S'
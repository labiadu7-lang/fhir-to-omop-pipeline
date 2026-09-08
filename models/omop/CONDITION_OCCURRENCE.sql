SELECT DISTINCT
    condition_occurrence_id,
    p.person_id,
    COALESCE(co.concept_id, 0) AS condition_concept_id,
    condition_start_date,
    condition_start_datetime,
    condition_end_date,
    condition_end_datetime,
    COALESCE(con.concept_id, 0) AS condition_type_concept_id,
    condition_status_concept_id,
    stop_reason,
    pro.provider_id,
    v.visit_occurrence_id,
    vi.visit_detail_id,
    condition_source_value,
    COALESCE(co.concept_id, 0) AS condition_source_concept_id,
    condition_status_source_value
FROM {{ ref("int_condition_occurrence")}} c
LEFT JOIN {{ ref("int_person")}} p
    ON c.patient_id = p.person_source_value
LEFT JOIN {{ ref("int_visit_occurrence")}} v
    ON c.encounter_id = v.encounter_id
LEFT JOIN {{ ref("int_provider")}} pro
    ON v.provider_id = pro.practitioner_id
LEFT JOIN {{ ref("int_visit_detail")}} vi
    ON c.visit_detail_id = vi.visit_detail_id
LEFT JOIN {{ ref('CONCEPT') }} AS co
    ON c.condition_source_value = co.concept_code
    AND co.vocabulary_id = 'SNOMED'
    AND co.standard_concept = 'S'
LEFT JOIN {{ ref('CONCEPT') }} AS con
    ON con.concept_name = 'EHR encounter record'
    AND con.domain_id = 'Type Concept'
    AND con.standard_concept = 'S'
WHERE co.domain_id = 'Condition'
   OR co.concept_id IS NULL
ORDER BY condition_occurrence_id

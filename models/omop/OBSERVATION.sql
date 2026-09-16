SELECT DISTINCT
    observation_id,
    p.person_id,
    COALESCE(c.concept_id, 0) AS observation_concept_id,
    observation_date,
    observation_datetime,
    COALESCE(co.concept_id, 0) AS observation_type_concept_id,
    value_as_number,
    value_as_string,
    value_as_concept_id,
    qualifier_concept_id,
    COALESCE(u.concept_id, NULL) AS unit_concept_id,
    pro.provider_id,
    v.visit_occurrence_id,
    vi.visit_detail_id,
    observation_source_value,
    COALESCE(c.concept_id, 0) AS observation_source_concept_id,
    unit_source_value,
    qualifier_source_value,
    value_source_value,
    observation_event_id,
    obs_event_field_concept_id
FROM {{ ref("int_observation")}} o
LEFT JOIN {{ ref("int_person")}} p
    ON o.patient_id = p.person_source_value
LEFT JOIN {{ ref("int_visit_occurrence")}} v
    ON o.encounter_id = v.encounter_id
LEFT JOIN {{ ref("int_provider")}} pro
    ON v.provider_id = pro.practitioner_id
LEFT JOIN {{ ref("int_visit_detail")}} vi
    ON o.visit_detail_id = vi.visit_detail_id
LEFT JOIN {{ ref('CONCEPT') }} c
    ON o.observation_source_value = c.concept_code
    AND c.vocabulary_id IN ('LOINC', 'SNOMED')
    AND c.standard_concept = 'S'
LEFT JOIN {{ ref('CONCEPT') }} AS co
    ON co.concept_name = 'EHR'
    AND co.domain_id = 'Type Concept'
    AND co.standard_concept = 'S'
LEFT JOIN {{ ref('CONCEPT') }} AS u
    ON o.unit_source_value = u.concept_code
    AND u.vocabulary_id = 'UCUM'
ORDER BY observation_id
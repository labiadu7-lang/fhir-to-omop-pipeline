SELECT
    measurement_id,
    p.person_id,
    v.visit_occurrence_id,
    COALESCE(c.concept_id, 0) AS measurement_concept_id,
    measurement_date,
    measurement_datetime,
    COALESCE(co.concept_id, 0) AS measurement_type_concept_id,
    operator_concept_id,
    value_as_number,
    value_as_concept_id,
    COALESCE(u.concept_id, 0) AS unit_concept_id,
    range_low,
    range_high,
    pro.provider_id,
    visit_detail_id,
    measurement_source_value,
    COALESCE(c.concept_id, 0) AS measurement_source_concept_id,
    unit_source_value,
    COALESCE(u.concept_id, 0) AS unit_source_concept_id,
    value_source_value,
    measurement_event_id,
    meas_event_field_concept_id
FROM {{ ref("int_measurement")}} m
LEFT JOIN {{ ref("int_person")}} p
    ON m.patient_id = p.person_source_value
LEFT JOIN {{ ref("int_visit_occurrence")}} v
    ON m.encounter_id = v.encounter_id
LEFT JOIN {{ ref("int_provider")}} pro
    ON v.provider_id = pro.practitioner_id
LEFT JOIN {{ ref('concept_table') }} c
    ON m.measurement_source_value = c.concept_code
    AND c.vocabulary_id = 'LOINC'
    AND c.standard_concept = 'S'
LEFT JOIN {{ ref('concept_table') }} AS co
    ON co.concept_name = 'EHR'
    AND co.domain_id = 'Type Concept'
    AND co.standard_concept = 'S'
LEFT JOIN {{ ref('concept_table') }} AS u
    ON m.unit_source_value = u.concept_code
    AND u.vocabulary_id = 'UCUM'




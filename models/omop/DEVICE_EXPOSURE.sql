SELECT DISTINCT
    device_exposure_id,
    p.person_id,
    COALESCE(co.concept_id, 0) AS device_concept_id,
    device_exposure_start_date,
    device_exposure_start_datetime,
    device_exposure_end_date,
    device_exposure_end_datetime,
    COALESCE(con.concept_id, 0) AS device_type_concept_id,
    unique_device_id,
    production_id,
    quantity,
    d.provider_id,
    d.visit_occurrence_id,
    vi.visit_detail_id,
    device_source_value,
    COALESCE(co.concept_id, 0) AS device_source_concept_id,
    unit_concept_id,
    unit_source_value,
    unit_source_concept_id
FROM {{ ref("int_device_exposure")}} d
LEFT JOIN {{ ref("int_person")}} p
    ON d.patient_id = p.person_source_value
LEFT JOIN {{ ref("int_visit_detail")}} vi
    ON d.visit_detail_id = vi.visit_detail_id
LEFT JOIN {{ ref('CONCEPT') }} co
    ON d.device_source_value = co.concept_code
    AND co.vocabulary_id = 'SNOMED'
    AND co.standard_concept = 'S'
    AND co.invalid_reason IS NULL
LEFT JOIN {{ ref('CONCEPT') }} AS con
    ON con.concept_name = 'EHR encounter record'
    AND con.domain_id = 'Type Concept'
    AND con.standard_concept = 'S'
ORDER BY device_exposure_id
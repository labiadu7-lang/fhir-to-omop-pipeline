SELECT DISTINCT
    drug_exposure_id,
    p.person_id,
    COALESCE(co.concept_id, 0) AS drug_concept_id,
    drug_exposure_start_date,
    drug_exposure_start_datetime,
    drug_exposure_end_date,
    drug_exposure_end_datetime,
    verbatim_end_date,
    COALESCE(con.concept_id, 0) AS drug_type_concept_id,
    stop_reason,
    refills,
    quantity,
    days_supply,
    sig,
    route_concept_id,
    lot_number,
    pro.provider_id,
    v.visit_occurrence_id,
    vi.visit_detail_id,
    drug_source_value,
    COALESCE(co.concept_id, 0) AS drug_source_concept_id,
    route_source_value,
    dose_unit_source_value
FROM {{ ref("int_drug_exposure")}} d
LEFT JOIN {{ ref("int_person")}} p
    ON d.patient_id = p.person_source_value
LEFT JOIN {{ ref("int_visit_detail")}} vi
    ON d.visit_detail_id = vi.visit_detail_id
LEFT JOIN {{ ref('CONCEPT') }} co
    ON d.drug_source_value = co.concept_code
    AND co.vocabulary_id IN ('RxNorm', 'CVX', 'SNOMED')
    AND co.standard_concept = 'S'
LEFT JOIN {{ ref('CONCEPT') }} con
    ON con.concept_name = 'EHR prescription'
    AND con.domain_id = 'Type Concept'
    AND con.standard_concept = 'S'
LEFT JOIN {{ ref("int_provider")}} pro
    ON d.practitioner_id = pro.practitioner_id
LEFT JOIN {{ ref("int_visit_occurrence")}} v
    ON d.encounter_id = v.encounter_id
ORDER BY drug_exposure_id

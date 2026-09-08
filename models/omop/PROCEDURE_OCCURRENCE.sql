SELECT DISTINCT
    procedure_occurrence_id,
    pe.person_id,
    COALESCE(co.concept_id, 0) AS procedure_concept_id,
    procedure_date,
    procedure_datetime,
    procedure_end_date,
    procedure_end_datetime,
    COALESCE(con.concept_id, 0) AS procedure_type_concept_id,
    modifier_concept_id,
    quantity,
    pro.provider_id,
    v.visit_occurrence_id,
    vi.visit_detail_id,
    procedure_source_value,
    COALESCE(co.concept_id, 0) AS procedure_source_concept_id,
    modifier_source_value
FROM {{ ref("int_procedure_occurrence")}} p
LEFT JOIN {{ ref("int_person")}} pe
    ON p.patient_id = pe.person_source_value
LEFT JOIN {{ ref("int_visit_occurrence")}} v
    ON p.encounter_id = v.encounter_id
LEFT JOIN {{ ref("int_provider")}} pro
    ON v.provider_id = pro.practitioner_id
LEFT JOIN {{ ref("int_visit_detail")}} vi
    ON p.visit_detail_id = vi.visit_detail_id
LEFT JOIN {{ ref('CONCEPT') }} AS co
    ON p.procedure_source_value = co.concept_code
   AND co.vocabulary_id IN ('CVX', 'SNOMED')
   AND co.standard_concept = 'S'
LEFT JOIN {{ ref('CONCEPT') }} AS con
    ON con.concept_name = 'EHR encounter record'
    AND con.domain_id = 'Type Concept'
    AND con.standard_concept = 'S'
WHERE co.domain_id = 'Procedure'
   OR co.concept_id IS NULL
ORDER BY procedure_occurrence_id

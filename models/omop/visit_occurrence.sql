WITH mapped_visits AS (
    SELECT 
        v.*,
        CASE 
            WHEN UPPER(v.visit_source_value) = 'EMER' THEN 'ER'
            WHEN UPPER(v.visit_source_value) = 'AMB'  THEN 'OP'
            WHEN UPPER(v.visit_source_value) = 'IMP'  THEN 'IP'
            ELSE v.visit_source_value 
        END AS mapped_concept_code
    FROM {{ ref('int_visit_occurrence') }} v
)
SELECT
    mv.visit_occurrence_id,
    p.person_id,
    COALESCE(co.concept_id, 0) AS visit_concept_id,
    mv.visit_start_date,
    mv.visit_start_datetime,
    mv.visit_end_date,
    mv.visit_end_datetime,
    COALESCE(con.concept_id, 0) AS visit_type_concept_id,
    pro.provider_id,
    ca.care_site_id,
    mv.visit_source_value,
    COALESCE(c.concept_id, 0) AS visit_source_concept_id,
    mv.admitted_from_concept_id,
    mv.admitted_from_source_value,
    mv.discharged_to_concept_id,
    mv.discharged_to_source_value,
    mv.preceding_visit_occurrence_id
FROM mapped_visits mv
LEFT JOIN {{ ref("int_person")}} p
    ON mv.patient_id = p.person_source_value
LEFT JOIN {{ ref("int_provider")}} pro
    ON mv.provider_id = pro.practitioner_id
LEFT JOIN {{ ref("int_care_site")}} ca
    ON mv.care_site_id = ca.organization_id
LEFT JOIN {{ ref('concept_table') }} c
    ON mv.visit_source_value = c.concept_code
    AND c.vocabulary_id = 'Visit'
    AND c.standard_concept = 'S'
LEFT JOIN {{ ref('concept_table') }} co
    ON mv.mapped_concept_code = co.concept_code
    AND co.vocabulary_id = 'Visit'
    AND co.standard_concept = 'S'
    AND co.invalid_reason IS NULL
LEFT JOIN {{ ref('concept_table') }} AS con
    ON con.concept_name = 'EHR encounter record'
    AND con.domain_id = 'Type Concept'
    AND con.standard_concept = 'S'
ORDER BY mv.visit_occurrence_id

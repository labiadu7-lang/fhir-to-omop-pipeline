SELECT DISTINCT
    p.provider_id,
    provider_name,
    npi,
    dea,
    specialty_concept_id,
    c.care_site_id,
    year_of_birth,
    gender_concept_id,
    provider_source_value,
    specialty_source_value,
    specialty_source_concept_id,
    gender_source_value,
    gender_source_concept_id
FROM {{ ref("int_provider")}} p
LEFT JOIN {{ ref("int_visit_occurrence")}} v
    ON p.practitioner_id = v.provider_id
LEFT JOIN {{ ref("int_care_site")}} c
    ON v.care_site_id = c.organization_id
ORDER BY p.provider_id

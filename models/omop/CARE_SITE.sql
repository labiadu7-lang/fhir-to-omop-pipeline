SELECT
    care_site_id,
    care_site_name,
    place_of_service_concept_id,
    l.location_id,
    care_site_source_value,
    place_of_service_source_value
FROM {{ ref("int_care_site")}} c
LEFT JOIN {{ ref("int_location")}} l
    ON c.organization_id = l.organization_id
ORDER BY care_site_id
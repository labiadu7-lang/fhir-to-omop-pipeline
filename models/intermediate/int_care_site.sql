SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY organization_id) AS care_site_id,
    organization_id,
    CAST(organization_name AS VARCHAR(255)) AS care_site_name,
    CAST(0 AS INTEGER) AS place_of_service_concept_id,
    CAST(NULL AS INTEGER) AS location_id,
    CAST(organization_id AS VARCHAR(50)) AS care_site_source_value,
    CAST(organization_type_display AS VARCHAR(50)) AS place_of_service_source_value
FROM {{ ref('stg_care_site') }}
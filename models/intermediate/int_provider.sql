SELECT
    ROW_NUMBER() OVER (ORDER BY provider_id) AS provider_id,
    provider_id AS practitioner_id,
    CAST(
        COALESCE(provider_given_name, '') || ' ' ||
        COALESCE(provider_family_name, '')
    AS VARCHAR(255)) AS provider_name,
    CAST(npi AS VARCHAR(20)) AS npi,
    CAST(NULL AS VARCHAR(20)) AS dea,
    CAST(0 AS INTEGER) AS specialty_concept_id,
    CAST(NULL AS INTEGER) AS care_site_id,
    CAST(NULL AS INTEGER) AS year_of_birth,
    CAST(0 AS INTEGER) AS gender_concept_id,
    CAST(provider_source_value AS VARCHAR(50)) AS provider_source_value,
    CAST(NULL AS VARCHAR(50)) AS specialty_source_value,
    CAST(0 AS INTEGER) AS specialty_source_concept_id,
    CAST(gender_source_value AS VARCHAR(50)) AS gender_source_value,
    CAST(0 AS INTEGER) AS gender_source_concept_id
FROM {{ ref('stg_provider') }}
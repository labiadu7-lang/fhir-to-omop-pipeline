SELECT
    'My FHIR to OMOP Pipeline' AS cdm_source_name,
    'FHIR2OMOP' AS cdm_source_abbreviation,
    'KWASI OPARE ADU LABI' AS cdm_holder,
    'Transformed from FHIR JSON resources using pyarrow, duckdb and dbt' AS source_description,
    'https://github.com/labiadu7-lang/fhir-to-omop-pipeline.git' AS source_documentation_reference,
    'dbt-duckdb pipeline' AS cdm_etl_reference,
    CAST('2026-08-14' AS DATE) AS source_release_date,
    CURRENT_DATE AS cdm_release_date,
    'v5.4' AS cdm_version,
    COALESCE(c.concept_id, 0) AS cdm_version_concept_id,
    (SELECT vocabulary_version FROM {{ ref('VOCABULARY') }} WHERE vocabulary_id = 'None') AS vocabulary_version
FROM {{ ref('CONCEPT') }} c
WHERE c.concept_code LIKE '%5.4%'
  AND c.vocabulary_id = 'CDM'
LIMIT 1

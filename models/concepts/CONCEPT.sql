SELECT
    CAST(concept_id AS INTEGER) AS concept_id,
    CAST(concept_name AS VARCHAR) AS concept_name,
    CAST(domain_id AS VARCHAR) AS domain_id,
    CAST(vocabulary_id AS VARCHAR) AS vocabulary_id,
    CAST(concept_class_id AS VARCHAR) AS concept_class_id,
    CAST(standard_concept AS VARCHAR) AS standard_concept,
    CAST(concept_code AS VARCHAR) AS concept_code,
    CAST(strptime(CAST(valid_start_date AS VARCHAR), '%Y%m%d') AS DATE) AS valid_start_date,
    CAST(strptime(CAST(valid_end_date AS VARCHAR), '%Y%m%d') AS DATE) AS valid_end_date,
    CAST(invalid_reason AS VARCHAR) AS invalid_reason
FROM read_csv_auto('data/concepts/CONCEPT.csv', delim='\t', header=true)
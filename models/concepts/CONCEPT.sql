
WITH raw_concept AS (
    SELECT * FROM read_csv_auto(
        'C:/Users/labia/Desktop/concepts/CONCEPT.csv', 
        delim = '\t', 
        header = true
    )
),
raw_cvx AS (
    SELECT * FROM read_csv_auto(
        'C:/Users/labia/Desktop/concepts/CONCEPT_cvx.csv', 
        delim = '\t', 
        header = true
    )
),
combined AS (
    SELECT * FROM raw_concept
    UNION ALL
    SELECT * FROM raw_cvx
)
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
FROM combined
WITH raw_data AS (
    SELECT * FROM read_csv(
        'data/concepts/CONCEPT_RELATIONSHIP.csv',
        delim = '\t', 
        header = true,
        auto_detect = false,
        columns = {
            'concept_id_1': 'VARCHAR',
            'concept_id_2': 'VARCHAR',
            'relationship_id': 'VARCHAR',
            'valid_start_date': 'VARCHAR',
            'valid_end_date': 'VARCHAR',
            'invalid_reason': 'VARCHAR'
        }
    )
)
SELECT 
    CAST(concept_id_1 AS INTEGER) AS concept_id_1,
    CAST(concept_id_2 AS INTEGER) AS concept_id_2,
    CAST(relationship_id AS VARCHAR) AS relationship_id,
    CAST(strptime(valid_start_date, '%Y%m%d') AS DATE) AS valid_start_date,
    CAST(strptime(valid_end_date, '%Y%m%d') AS DATE) AS valid_end_date,
    CAST(invalid_reason AS VARCHAR) AS invalid_reason
FROM raw_data
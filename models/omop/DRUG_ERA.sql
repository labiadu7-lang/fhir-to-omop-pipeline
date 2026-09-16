


WITH drug_ingredients AS (
    SELECT
        de.person_id,

        ca.ancestor_concept_id AS drug_concept_id,
        de.drug_exposure_start_date,
        COALESCE(de.drug_exposure_end_date, de.drug_exposure_start_date) AS drug_exposure_end_date
    FROM {{ ref('DRUG_EXPOSURE') }} de
    INNER JOIN {{ ref('CONCEPT_ANCESTOR') }} ca
        ON de.drug_concept_id = ca.descendant_concept_id
    INNER JOIN {{ ref('CONCEPT') }} c
        ON ca.ancestor_concept_id = c.concept_id
    WHERE de.drug_concept_id != 0
      AND c.concept_class_id = 'Ingredient'
),

window_groups AS (
    SELECT
        person_id,
        drug_concept_id,
        drug_exposure_start_date,
        drug_exposure_end_date,
        MAX(drug_exposure_end_date) OVER (
            PARTITION BY person_id, drug_concept_id
            ORDER BY drug_exposure_start_date, drug_exposure_end_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS previous_max_end_date
    FROM drug_ingredients
),

era_starts AS (
    SELECT
        *,
        CASE
            WHEN previous_max_end_date IS NULL THEN 1
            WHEN drug_exposure_start_date - previous_max_end_date > 30 THEN 1
            ELSE 0
        END AS is_start
    FROM window_groups
),

era_groups AS (
    SELECT
        *,
        SUM(is_start) OVER (
            PARTITION BY person_id, drug_concept_id
            ORDER BY drug_exposure_start_date, drug_exposure_end_date
        ) AS era_group_id
    FROM era_starts
)

SELECT
    ROW_NUMBER() OVER (ORDER BY person_id, drug_concept_id) AS drug_era_id,
    person_id,
    drug_concept_id,
    MIN(drug_exposure_start_date) AS drug_era_start_date,
    MAX(drug_exposure_end_date) AS drug_era_end_date,
    COUNT(*) AS drug_exposure_count,
    CAST(NULL AS INT) AS gap_days
FROM era_groups
GROUP BY person_id, drug_concept_id, era_group_id

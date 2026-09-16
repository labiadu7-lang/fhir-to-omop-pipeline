WITH condition_events AS (
    SELECT
        person_id,
        condition_concept_id,
        condition_start_date,
        COALESCE(condition_end_date, condition_start_date) AS condition_end_date
    FROM {{ ref('CONDITION_OCCURRENCE') }}
    WHERE condition_concept_id != 0
),
window_groups AS (
    SELECT
        person_id,
        condition_concept_id,
        condition_start_date,
        condition_end_date,
        MAX(condition_end_date) OVER (
            PARTITION BY person_id, condition_concept_id
            ORDER BY condition_start_date, condition_end_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS previous_max_end_date
    FROM condition_events
),
era_starts AS (
    SELECT
        *,
        CASE
            WHEN previous_max_end_date IS NULL THEN 1
            WHEN condition_start_date - previous_max_end_date > 30 THEN 1
            ELSE 0
        END AS is_start
    FROM window_groups
),
era_groups AS (
    SELECT
        *,
        SUM(is_start) OVER (
            PARTITION BY person_id, condition_concept_id
            ORDER BY condition_start_date, condition_end_date
        ) AS era_group_id
    FROM era_starts
)
SELECT
    ROW_NUMBER() OVER (ORDER BY person_id, condition_concept_id) AS condition_era_id,
    person_id,
    condition_concept_id,
    MIN(condition_start_date) AS condition_era_start_date,
    MAX(condition_end_date) AS condition_era_end_date,
    COUNT(*) AS condition_occurrence_count
FROM era_groups
GROUP BY person_id, condition_concept_id, era_group_id

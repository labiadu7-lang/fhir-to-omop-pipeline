SELECT
    location_id,

    -- Foreign keys for joining to Person / Care Site (to be dropped in final OMOP output)
    CAST(patient_id AS VARCHAR(50)) AS patient_id,
    CAST(organization_id AS VARCHAR(50)) AS organization_id,

    CAST(address_1 AS VARCHAR(50)) AS address_1,
    CAST(NULL AS VARCHAR(50)) AS address_2,
    CAST(city AS VARCHAR(50)) AS city,
    CAST(state AS VARCHAR(2)) AS state,
    CAST(zip AS VARCHAR(9)) AS zip,
    CAST(NULL AS VARCHAR(20)) AS country,

    CAST(NULL AS VARCHAR(50)) AS location_source_value,
    CAST(0 AS INTEGER) AS country_concept_id,
    CAST(country AS VARCHAR(80)) AS country_source_value,

    CAST(latitude AS FLOAT) AS latitude,
    CAST(longitude AS FLOAT) AS longitude

FROM {{ ref('stg_location') }}
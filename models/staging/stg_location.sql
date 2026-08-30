WITH raw_entries AS (
    SELECT
        UNNEST(
            CAST(
                json_extract(json_content, '$.entry')
                AS JSON[]
            )
        ) AS entry_element
    FROM {{ source('fhir', 'fhir_bundles') }}
),

patient_location_staging AS (
    SELECT DISTINCT
        CAST(entry_element.resource.id AS VARCHAR) AS patient_id,
        CAST(NULL AS VARCHAR) AS organization_id,
        CAST(json_extract_string(address_elem, '$.line[0]') AS VARCHAR) AS address_1,
        CAST(json_extract_string(address_elem, '$.city') AS VARCHAR) AS city,
        CAST(json_extract_string(address_elem, '$.state') AS VARCHAR) AS state,
        CAST(json_extract_string(address_elem, '$.postalCode') AS VARCHAR) AS zip,
        CAST(json_extract_string(address_elem, '$.country') AS VARCHAR) AS country,
        CAST(json_extract(address_elem, '$.extension[0].extension[0].valueDecimal') AS DOUBLE) AS latitude,
        CAST(json_extract(address_elem, '$.extension[0].extension[1].valueDecimal') AS DOUBLE) AS longitude
    FROM raw_entries,
         UNNEST(CAST(json_extract(entry_element.resource, '$.address') AS JSON[])) AS t(address_elem)
    WHERE CAST(json_extract_string(entry_element.resource, '$.resourceType') AS VARCHAR) = 'Patient'
      AND json_extract(entry_element.resource, '$.address') IS NOT NULL
),

care_site_location_staging AS (
    SELECT DISTINCT
        CAST(NULL AS VARCHAR) AS patient_id,
        CAST(entry_element.resource.id AS VARCHAR) AS organization_id,
        CAST(json_extract_string(address_elem, '$.line[0]') AS VARCHAR) AS address_1,
        CAST(json_extract_string(address_elem, '$.city') AS VARCHAR) AS city,
        CAST(json_extract_string(address_elem, '$.state') AS VARCHAR) AS state,
        CAST(json_extract_string(address_elem, '$.postalCode') AS VARCHAR) AS zip,
        CAST(json_extract_string(address_elem, '$.country') AS VARCHAR) AS country,
        CAST(NULL AS DOUBLE) AS latitude,
        CAST(NULL AS DOUBLE) AS longitude
    FROM raw_entries,
         UNNEST(CAST(json_extract(entry_element.resource, '$.address') AS JSON[])) AS t(address_elem)
    WHERE CAST(json_extract_string(entry_element.resource, '$.resourceType') AS VARCHAR) = 'Organization'
      AND json_extract(entry_element.resource, '$.address') IS NOT NULL
),

combined_addresses AS (
    SELECT * FROM patient_location_staging
    UNION ALL
    SELECT * FROM care_site_location_staging
)

SELECT DISTINCT
    ROW_NUMBER() OVER (
        ORDER BY
            address_1,
            city,
            state,
            zip,
            country
    ) AS location_id,
    patient_id,
    organization_id,
    address_1,
    city,
    state,
    zip,
    country,
    latitude,
    longitude
FROM combined_addresses
WHERE address_1 IS NOT NULL
ORDER BY location_id ASC
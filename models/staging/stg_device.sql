WITH unnested_entries AS (
    SELECT
        UNNEST(
            CAST(
                json_extract(json_content, '$.entry')
                AS JSON[]
            )
        ) AS entry
    FROM {{ source('fhir', 'fhir_bundles') }}
),

device_info AS (
    SELECT
        CAST(entry.resource.id AS VARCHAR) AS device_id,
        REPLACE(CAST(entry.resource.patient.reference AS VARCHAR), 'urn:uuid:', '') AS patient_id,
        CAST(entry.resource.status AS VARCHAR) AS device_status,
        CAST(entry.resource.manufactureDate AS TIMESTAMP) AS manufacture_datetime,
        CAST(entry.resource.expirationDate AS TIMESTAMP) AS expiration_datetime,
        UNNEST(CAST(entry.resource.udiCarrier AS JSON[])) AS udi_value,
        UNNEST(CAST(entry.resource.deviceName AS JSON[])) AS device_name,
        UNNEST(CAST(entry.resource.type.coding AS JSON[])) AS device_type
    FROM unnested_entries
    WHERE CAST(entry.resource.resourceType AS VARCHAR) = '"Device"'
)

SELECT
    device_id,
    REPLACE(patient_id, '"', '') AS patient_id,
    device_status,
    manufacture_datetime,
    expiration_datetime,
    CAST(udi_value ->> 'deviceIdentifier' AS VARCHAR) AS device_identifier,
    CAST(udi_value ->> 'carrierHRF' AS VARCHAR) AS device_udi,
    CAST(device_name ->> 'name' AS VARCHAR) AS device_name,
    CAST(device_type ->> 'code' AS VARCHAR) AS device_code,
    CAST(device_type ->> 'display' AS VARCHAR) AS device_display
FROM device_info
WITH unnested_entries AS (
    SELECT
        UNNEST(entry) AS entry,
    FROM {{ source('fhir', 'fhir_bundles')}}
),

device_info AS (
SELECT
    entry.resource.id AS device_id,
    REPLACE(entry.resource.patient.reference, 'urn:uuid:', '') AS patient_id,

    entry.resource.status AS device_status,
    entry.resource.manufactureDate::TIMESTAMP AS manufacture_datetime,
    entry.resource.expirationDate::TIMESTAMP AS expiration_datetime,

    UNNEST(CAST(entry.resource.udiCarrier AS JSON[])) AS udi_value,
    UNNEST(CAST(entry.resource.deviceName AS JSON[])) AS device_name,
    UNNEST(CAST(entry.resource.type.coding AS JSON[])) AS device_type

FROM unnested_entries
WHERE entry.resource.resourceType = 'Device'
)


SELECT
    device_id,
    CAST(patient_id AS UUID) AS patient_id,
    device_status,
    manufacture_datetime,
    expiration_datetime,
    udi_value ->> 'deviceIdentifier' AS device_identifier,
    udi_value ->> 'carrierHRF' AS device_udi,
    device_name ->> 'name' AS device_name,
    device_type ->> 'code' AS device_code,
    device_type ->> 'display' AS device_display
FROM device_info
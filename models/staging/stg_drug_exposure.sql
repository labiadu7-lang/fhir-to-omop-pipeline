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

medication_requests AS (
    SELECT
        CAST(entry.resource.id AS VARCHAR) AS medication_request_id,
        REPLACE(CAST(entry.resource.subject.reference AS VARCHAR), 'urn:uuid:', '') AS patient_id,
        REPLACE(CAST(entry.resource.encounter.reference AS VARCHAR), 'urn:uuid:', '') AS encounter_id,
        REPLACE(CAST(entry.resource.requester.reference AS VARCHAR), 'urn:uuid:', '') AS provider_id,
        CAST(entry.resource.status AS VARCHAR) AS medication_request_status,
        CAST(entry.resource.intent AS VARCHAR) AS medication_request_intent,
        CAST(entry.resource.authoredOn AS TIMESTAMP) AS authored_datetime,
        CAST(entry.resource.medicationCodeableConcept.text AS VARCHAR) AS medication_text,
        UNNEST(CAST(entry.resource.medicationCodeableConcept.coding AS JSON[])) AS medication_value,
        UNNEST(CAST(entry.resource.dosageInstruction AS JSON[])) AS dosage
    FROM unnested_entries
    WHERE CAST(entry.resource.resourceType AS VARCHAR) = '"MedicationRequest"'
),

immunizations AS (
    SELECT
        CAST(entry.resource.id AS VARCHAR) AS medication_request_id,
        REPLACE(CAST(entry.resource.patient.reference AS VARCHAR), 'urn:uuid:', '') AS patient_id,
        REPLACE(CAST(entry.resource.encounter.reference AS VARCHAR), 'urn:uuid:', '') AS encounter_id,
        CAST(NULL AS VARCHAR) AS provider_id,
        CAST(entry.resource.status AS VARCHAR) AS medication_request_status,
        CAST(NULL AS VARCHAR) AS medication_request_intent,
        CAST(entry.resource.occurrenceDateTime AS TIMESTAMP) AS authored_datetime,
        CAST(entry.resource.vaccineCode.text AS VARCHAR) AS medication_text,
        UNNEST(CAST(entry.resource.vaccineCode.coding AS JSON[])) AS medication_value,
        CAST(NULL AS JSON) AS dosage
    FROM unnested_entries
    WHERE CAST(entry.resource.resourceType AS VARCHAR) = '"Immunization"'
),

combined_sources AS (
    SELECT * FROM medication_requests
    UNION ALL
    SELECT * FROM immunizations
)

SELECT
    medication_request_id,
    REPLACE(patient_id, '"', '') AS patient_id,
    encounter_id,
    provider_id AS practitioner_id,
    medication_request_status,
    medication_request_intent,
    authored_datetime,
    medication_text,
    CAST(medication_value ->> 'code' AS VARCHAR) AS medication_code,
    CAST(medication_value ->> 'display' AS VARCHAR) AS medication_display,
    CAST(dosage ->> 'sequence' AS VARCHAR) AS dosage_sequence,
    CAST(dosage ->> 'asNeededBoolean' AS VARCHAR) AS as_needed
FROM combined_sources
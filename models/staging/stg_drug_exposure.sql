WITH unnested_entries AS (
    SELECT
        UNNEST(entry) AS entry
    FROM {{ source('fhir', 'fhir_bundles') }}
),

medication_requests AS (
    SELECT
        entry.resource.id AS medication_request_id,
        REPLACE(entry.resource.subject.reference, 'urn:uuid:', '') AS patient_id,
        REPLACE(entry.resource.encounter.reference, 'urn:uuid:', '') AS encounter_id,
        REPLACE(entry.resource.requester.reference, 'urn:uuid:', '') AS provider_id,

        entry.resource.status AS medication_request_status,
        entry.resource.intent AS medication_request_intent,
        entry.resource.authoredOn AS authored_datetime,
        entry.resource.medicationCodeableConcept.text AS medication_text,

        UNNEST(CAST(entry.resource.medicationCodeableConcept.coding AS JSON[])) AS medication_value,
        UNNEST(CAST(entry.resource.dosageInstruction AS JSON[])) AS dosage

    FROM unnested_entries
    WHERE entry.resource.resourceType = 'MedicationRequest'
),

immunizations AS (
    SELECT
        entry.resource.id AS medication_request_id,
        REPLACE(entry.resource.patient.reference, 'urn:uuid:', '') AS patient_id,
        REPLACE(entry.resource.encounter.reference, 'urn:uuid:', '') AS encounter_id,
        CAST(NULL AS VARCHAR) AS provider_id,

        entry.resource.status AS medication_request_status,
        CAST(NULL AS VARCHAR) AS medication_request_intent,
        entry.resource.occurrenceDateTime AS authored_datetime,
        entry.resource.vaccineCode.text AS medication_text,

        UNNEST(CAST(entry.resource.vaccineCode.coding AS JSON[])) AS medication_value,
        CAST(NULL AS JSON) AS dosage

    FROM unnested_entries
    WHERE entry.resource.resourceType = 'Immunization'
),

combined_sources AS (
    SELECT * FROM medication_requests
    UNION ALL
    SELECT * FROM immunizations
)

SELECT
    medication_request_id,
    CAST(patient_id AS UUID) AS patient_id,
    CAST(encounter_id AS UUID) AS encounter_id,
    CAST(provider_id AS UUID) AS practitioner_id,
    medication_request_status,
    medication_request_intent,
    authored_datetime,
    medication_text,
    medication_value ->> 'code' AS medication_code,
    medication_value ->> 'display' AS medication_display,
    dosage ->> 'sequence' AS dosage_sequence,
    dosage ->> 'asNeededBoolean' AS as_needed
FROM combined_sources
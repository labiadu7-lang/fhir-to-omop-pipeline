# FHIR R4 to OMOP CDM

This project mapped FHIR R4 data to the OMOP Common Data Model (CDM).

The source FHIR dataset contained 1,180 synthetic patients. Python, PyArrow, and DuckDB were used to convert the nested FHIR JSON data into Parquet format and expose it through a DuckDB raw data layer. dbt was then used to transform the data through staging models, intermediate models, and finally the OMOP CDM tables.

dbt tests were used to check uniqueness, null constraints, and relationships between primary and foreign keys. Transformations used SQL-based relational modeling across OMOP clinical domains. FHIR resources were processed according to their semantic relationships. Patient, visit, concept, and clinical-event relationships were maintained throughout the transformation using relational techniques and multi-table joins to establish the required grain where the source FHIR data did not explicitly provide those relationships.

Source clinical codes were mapped to standard OMOP concepts using the required OHDSI vocabulary tables.

The resulting CDM was evaluated using the OHDSI Data Quality Dashboard (DQD). The CDM achieved 100% structural validation and approximately 98% across the evaluated completeness, plausibility, and conformance checks. The pipeline also completed with zero SQL execution errors.

The pipeline is script-based and can be rerun from the source FHIR dataset to regenerate the OMOP database. The project is designed to run locally using Python, DuckDB, SQL, and dbt.

SQL transformation models are provided in the `models/` directory, with dbt tests defined in the corresponding `schema.yml` files under `models/omop/`.

## Building and Validating the CDM

### 1. Clone the repository

Clone the repository to your local machine.
```bash
git clone https://github.com/labiadu7-lang/fhir-to-omop-pipeline.git fhir_to_omop
cd fhir_to_omop
```

### 2. Install Python dependencies

Run the following command from the project root:

```bash
pip install -r requirements.txt
```

### 3. Download the synthetic FHIR R4 dataset

Download the synthetic patient 1K FHIR R4 dataset from [Synthea Downloads](https://synthea.mitre.org/downloads).

### 4. Place the FHIR data in the project

Extract the FHIR JSON files into:

```text
data/fhir_raw/
```

in the project root.

### 5. Download the required OMOP vocabularies

Go to [OHDSI Athena](https://athena.ohdsi.org/) and create an account.

Navigate to **Downloads** and select the following vocabularies:

**OMOP Extension, RxNorm Extension, ABMS, ICD10CM, SPL, Medicare Specialty, NUCC, Ethnicity, Revenue Code, ICD10PCS, ICD10, Cohort, CMS Place of Service, Race, Gender, NDC, RxNorm, LOINC, HCPCS, ICD9Proc, ICD9CM, CVX**

Request access to the selected vocabularies and download them.

### 6. Place the vocabulary files in the project

Extract the downloaded vocabulary files into:

```text
data/concepts/
```

These vocabularies provide the standard OMOP concepts required to map source clinical codes for drugs, conditions, procedures, measurements, and other clinical data.

> **External data dependency:** The FHIR dataset and OHDSI vocabulary files are not included in the repository because of their size and distribution requirements. The pipeline is therefore reproducible with these external data dependencies.

### 7. Create the raw Parquet layer

From the project root, run:

```bash
python parquet_raw_maker.py
```

This converts the FHIR JSON files into Parquet and configures the resulting Parquet data as the raw layer within DuckDB.

### 8. Build the OMOP CDM

Run:

```bash
dbt build --profiles-dir "."
```

This builds the dbt models and runs the configured dbt tests.

### 9. Inspect the resulting database

Connect the generated `dev.duckdb` file to a database management tool such as DBeaver.

The resulting OMOP tables can be found in the:

```text
main_omop
```

schema.

### 10. Run the OHDSI data-quality validation

The validation scripts are located in:

```text
r_scripts/
```

Run the appropriate R scripts using RStudio or another R environment.

### 11. Configure the database path

Before running the validation scripts, change:

```text
"path/to/your/dev.duckdb"
```

to the local path of your generated `dev.duckdb` database.

### 12. Install R dependencies

Install the required R packages and libraries when prompted by the validation scripts.

### 13. Configure Java

The OHDSI validation workflow requires a 64-bit Java Development Kit (JDK).

#### Windows

1. Download and install a 64-bit JDK, such as [Eclipse Adoptium](https://adoptium.net/).
2. Search for **Edit the system environment variables** and open it.
3. Click **Environment Variables**.
4. Under **System Variables**, click **New**.
5. Create the following variable:

```text
Variable name: JAVA_HOME
Variable value: C:\Program Files\Eclipse Adoptium\jdk-...
```
Set the Variable value to the directory where the Eclipse Adoptium JDK was installed.

6. Click **OK**.

Restart R/RStudio and any open command prompts so that the new environment variable is recognized.


### 14. Run the validation scripts

Run the R scripts in `r_scripts/`. The validation results can then be viewed through the resulting Shiny interactive browser interface.

## Reproducibility
The Java configuration steps are environment-specific. The validation workflow was tested on Windows. 


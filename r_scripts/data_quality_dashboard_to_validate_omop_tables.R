Sys.getenv("JAVA_HOME")
library(DataQualityDashboard)
library(shiny)

setwd("C:/Users/labia/PycharmProjects/fhir_to_omop")

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "duckdb",
  server = "C:/Users/labia/PycharmProjects/fhir_to_omop/dev.duckdb"
)

DataQualityDashboard::executeDqChecks(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = "main_omop",
  vocabDatabaseSchema = "main_concepts",
  resultsDatabaseSchema = "main_omop",
  cdmSourceName = "FHIR to OMOP Pipeline",
  cdmVersion = "5.4",
  outputFolder = "dqd_output",
  verboseMode = TRUE,
  writeToTable = FALSE,
  tablesToExclude = c(
    "SOURCE_TO_CONCEPT_MAP", 
    "SPECIMEN", 
    "NOTE", 
    "NOTE_NLP", 
    "PAYER_PLAN_PERIOD", 
    "COST",
    "DOSE_ERA",
    "EPISODE",
    "EPISODE_EVENT",
    "METADATA",
    "FACT_RELATIONSHIP",
    "VISIT DETAIL",
    "COHORT_DEFINITION",
    "COHORT",
    "DRUG_STRENGTH"
  )
)


json_files <- list.files("dqd_output", pattern = "\\.json$", full.names = TRUE)
latest_json <- normalizePath(json_files[which.max(file.info(json_files)$mtime)])


DataQualityDashboard::viewDqDashboard(
  jsonPath = latest_json
)

import glob
import os
import duckdb
import pyarrow as pa
import pyarrow.parquet as pq

input_dir = "data/fhir_raw/*.json"
output_parquet = "data/fhir_parquet.parquet"
duckdb_path = "dev.duckdb"


schema = pa.schema([
    ('file_name', pa.string()),
    ('json_content', pa.string())
])

writer = pq.ParquetWriter(output_parquet, schema, compression='snappy')

file_list = glob.glob(input_dir)
print(f"Found {len(file_list)} files. Starting conversion...")

for i, file_path in enumerate(file_list):
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            raw_text = f.read()

        file_name = os.path.basename(file_path)

        batch_table = pa.Table.from_pydict({
            'file_name': [file_name],
            'json_content': [raw_text]
        }, schema=schema)

        writer.write_table(batch_table)

        if (i + 1) % 100 == 0:
            print(f"Processed {i + 1}/{len(file_list)} files...")

    except Exception as e:
        print(f"Error processing {file_path}: {e}")

writer.close()
print("Parquet file created successfully!")

con = duckdb.connect(duckdb_path)

con.sql(f"""
CREATE SCHEMA IF NOT EXISTS parquet_raw;
DROP VIEW IF EXISTS parquet_raw.fhir_bundles;
DROP TABLE IF EXISTS parquet_raw.fhir_bundles;

CREATE VIEW parquet_raw.fhir_bundles AS 
SELECT * FROM read_parquet('{output_parquet}');
""")

con.close()
print(f"Table parquet_raw.fhir_bundles created successfully in {duckdb_path}!")
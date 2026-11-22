# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "b9aa9f55-0b24-4b07-a21e-85688ffbb9fc",
# META       "default_lakehouse_name": "lh_urban_analytics",
# META       "default_lakehouse_workspace_id": "b014008e-8cae-4da2-b22b-6e9b6b29922e",
# META       "known_lakehouses": [
# META         {
# META           "id": "b9aa9f55-0b24-4b07-a21e-85688ffbb9fc"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

import json

BASE_PATH = "Files"

TAXI_PATH = f"{BASE_PATH}/nyc_taxi/yellow_tripdata_2025-06.parquet"
ECB_PATH = f"{BASE_PATH}/ecb/data.csv"
GDP_PATH = f"{BASE_PATH}/world_bank/NY.GDP.MKTP.CD_full.json"
OPENAQ_PATH = f"{BASE_PATH}/openaq/openaq_locations.json"

print("Bronze layer has started")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

folders = ["nyc_taxi", "ecb", "world_bank", "openaq"]

for folder in folders:
    print(f"\n--- {folder.upper()} ---")

    files = mssparkutils.fs.ls(f"{BASE_PATH}/{folder}")

    for file in files:
        print(f"File: {file.name}")
        print(f"Size: {file.size:,} bytes")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df_taxi = spark.read.parquet(TAXI_PATH)

taxi_count = df_taxi.count()

print("NYC Taxi")
print("Total records:", taxi_count)
print("Total columns:", len(df_taxi.columns))

df_taxi.printSchema()

display(df_taxi.limit(5))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df_ecb = (
    spark.read
    .option("header", True)
    .option("inferSchema", True)
    .csv(ECB_PATH)
)

ecb_count = df_ecb.count()

print("ECB Exchange Rates")
print("Total records:", ecb_count)
print("Total columns:", len(df_ecb.columns))

df_ecb.printSchema()

display(df_ecb.limit(5))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

gdp_lines = spark.read.text(GDP_PATH).collect()

gdp_raw = "\n".join(row.value for row in gdp_lines)

gdp_payload = json.loads(gdp_raw)

gdp_metadata = gdp_payload[0]
gdp_records = gdp_payload[1]

df_gdp = spark.read.json(
    spark.sparkContext.parallelize(
        [json.dumps(record) for record in gdp_records]
    )
)

gdp_count = df_gdp.count()

print("World Bank GDP")
print("API total:", gdp_metadata["total"])
print("Total records:", gdp_count)
print("First year:", min(record["date"] for record in gdp_records))
print("Last year:", max(record["date"] for record in gdp_records))

df_gdp.printSchema()

display(df_gdp.limit(5))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

openaq_lines = spark.read.text(OPENAQ_PATH).collect()

openaq_raw = "\n".join(row.value for row in openaq_lines)

openaq_data = json.loads(openaq_raw)

openaq_metadata = openaq_data["meta"]
openaq_records = openaq_data["results"]

df_openaq = spark.read.json(
    spark.sparkContext.parallelize(
        [json.dumps(record, ensure_ascii=False) for record in openaq_records]
    )
)

openaq_count = df_openaq.count()

print("OpenAQ Locations")
print("Total locations:", openaq_count)
print("Total sensors:", sum(len(record.get("sensors", [])) for record in openaq_records))

df_openaq.printSchema()

display(df_openaq.limit(5))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

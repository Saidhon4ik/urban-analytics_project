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

from pyspark.sql import functions as F

bronze_taxi = "Files/nyc_taxi/yellow_tripdata_2025-06.parquet"
bronze_locations = "bronze_openaq_locations"
bronze_measurements = "bronze_openaq_daily_measurements"
bronze_ecb = "bronze_ecb_exchange_rates"
bronze_gdp = "bronze_world_bank_gdp"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

tables = [
    bronze_locations,
    bronze_measurements,
    bronze_ecb,
    bronze_gdp
]

for table in tables:
    print("\nTABLE:", table)

    df = spark.table(table)

    df.printSchema()

    print("Rows:", df.count())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

taxi = spark.read.parquet(bronze_taxi)

taxi = taxi.toDF(*[c.lower() for c in taxi.columns])

taxi = taxi.withColumn(
    "pickup_date",
    F.to_date("tpep_pickup_datetime")
)

taxi = taxi.withColumn(
    "dropoff_date",
    F.to_date("tpep_dropoff_datetime")
)

taxi = taxi.dropDuplicates()

taxi.write.format("delta").mode("overwrite").saveAsTable(
    "silver_nyc_taxi_trips"
)

print("Silver Taxi rows:", taxi.count())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

locations = spark.table(bronze_locations)

locations = locations.dropDuplicates()

locations.write.format("delta").mode("overwrite").saveAsTable(
    "silver_openaq_locations"
)

measurements = spark.table(bronze_measurements)

measurements = measurements.withColumn(
    "measurement_date",
    F.to_date("period_from_utc")
)

measurements = measurements.dropDuplicates()

measurements.write.format("delta").mode("overwrite").saveAsTable(
    "silver_openaq_daily_measurements"
)

print("Silver locations:", locations.count())
print("Silver measurements:", measurements.count())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

ecb = spark.table(bronze_ecb)

ecb = ecb.withColumnRenamed("OBS_VALUE", "exchange_rate")

ecb = ecb.withColumn(
    "rate_date",
    F.to_date("TIME_PERIOD")
)

ecb = ecb.withColumn("base_currency", F.lit("EUR"))
ecb = ecb.withColumn("target_currency", F.lit("USD"))

ecb.write.format("delta").mode("overwrite").option(
    "overwriteSchema", "true"
).saveAsTable("silver_ecb_exchange_rates")

gdp = spark.table(bronze_gdp)

gdp = gdp.withColumnRenamed("countryiso3code", "country_iso3")
gdp = gdp.withColumnRenamed("date", "year")
gdp = gdp.withColumnRenamed("value", "gdp_usd")

gdp.write.format("delta").mode("overwrite").saveAsTable(
    "silver_world_bank_gdp"
)

print("Silver ECB:", ecb.count())
print("Silver GDP:", gdp.count())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

tables = [
    "silver_nyc_taxi_trips",
    "silver_openaq_locations",
    "silver_openaq_daily_measurements",
    "silver_ecb_exchange_rates",
    "silver_world_bank_gdp"
]

for table in tables:
    df = spark.table(table)

    print("\nTABLE:", table)
    print("Rows:", df.count())
    print("Columns:", len(df.columns))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

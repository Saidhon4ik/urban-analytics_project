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
# META     },
# META     "warehouse": {
# META       "known_warehouses": []
# META     }
# META   }
# META }

# CELL ********************

df = spark.read.parquet(
    "Files/nyc_taxi/yellow_tripdata_2025-06.parquet"
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df.printSchema()


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

display(df.limit(10))


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

print(df.count())
print(len(df.columns))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import col, count, when

missing_values = df.select([
    count(when(col(c).isNull(), c)).alias(c)
    for c in df.columns
])

display(missing_values)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

total_records = df.count()
unique_records = df.dropDuplicates().count()

print("Duplicate records:", total_records - unique_records)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

display(df.describe())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import min, max

df.select(
    min("tpep_pickup_datetime").alias("earliest_pickup"),
    max("tpep_pickup_datetime").alias("latest_pickup")
).show()


# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import col, sum, when

df.select([
    sum(when(col(c).isNull(), 1).otherwise(0)).alias(c)
    for c in df.columns
]).show(vertical=True)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import col, when, count

df.groupBy(
    when(col("passenger_count").isNull(), "NULL")
    .otherwise("NOT NULL")
    .alias("passenger_count_status")
).count().show()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import col

null_pattern = df.filter(
    col("passenger_count").isNull() &
    col("RatecodeID").isNull() &
    col("store_and_fwd_flag").isNull() &
    col("congestion_surcharge").isNull() &
    col("Airport_fee").isNull()
)

print("Rows with all five columns NULL:", null_pattern.count())

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

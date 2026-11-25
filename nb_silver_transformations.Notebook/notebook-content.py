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
from pyspark.sql.window import Window

BRONZE_ECB = "bronze_ecb_exchange_rates"
BRONZE_OPENAQ_LOCATIONS = "bronze_openaq_locations"
BRONZE_OPENAQ_MEASUREMENTS = "bronze_openaq_daily_measurements"
BRONZE_WORLD_BANK = "NY GDP MKTP CD_full json"

SILVER_TAXI = "silver_nyc_taxi_trips"
SILVER_OPENAQ_LOCATIONS = "silver_openaq_locations"
SILVER_OPENAQ_MEASUREMENTS = "silver_openaq_daily_measurements"
SILVER_ECB = "silver_ecb_exchange_rates"
SILVER_GDP = "silver_world_bank_gdp"

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

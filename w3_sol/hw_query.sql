-- Initialize external table by connecting to Parquet files in Google Cloud Storage
CREATE OR REPLACE EXTERNAL TABLE `eastern-amp-449614-e1.yellow_taxi_dataset.external_yellow_taxi_data`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://yellow_taxi_gcs/yellow_tripdata_2024-*.parquet']
);

-- Validate data structure by examining sample records
SELECT * FROM `eastern-amp-449614-e1.yellow_taxi_dataset.external_yellow_taxi_data` limit 10;

-- Convert external table into native BigQuery table for improved query performance
CREATE OR REPLACE TABLE `eastern-amp-449614-e1.yellow_taxi_dataset.regular_yellow_taxi_data` 
AS SELECT * FROM `eastern-amp-449614-e1.yellow_taxi_dataset.external_yellow_taxi_data`;

-- Calculate total number of taxi rides in dataset
SELECT count(*) as trips 
FROM `eastern-amp-449614-e1.yellow_taxi_dataset.regular_yellow_taxi_data`;

-- Compare unique pickup location counts between external and regular tables
SELECT COUNT(DISTINCT PULocationID) AS distinct_pulocation_count 
FROM `eastern-amp-449614-e1.yellow_taxi_dataset.external_yellow_taxi_data`;

SELECT COUNT(DISTINCT PULocationID) AS distinct_pulocation_count 
FROM `eastern-amp-449614-e1.yellow_taxi_dataset.regular_yellow_taxi_data`;

-- Examine pickup location data processing impact
SELECT PULocationID 
FROM `eastern-amp-449614-e1.yellow_taxi_dataset.regular_yellow_taxi_data`;

-- Analyze pickup and dropoff location patterns
SELECT PULocationID, DOLocationID
FROM `eastern-amp-449614-e1.yellow_taxi_dataset.regular_yellow_taxi_data`;

-- Find rides with zero fare charges
SELECT count(*) as trips 
FROM `eastern-amp-449614-e1.yellow_taxi_dataset.regular_yellow_taxi_data` 
WHERE fare_amount = 0;

-- Create performance-optimized table using date partitioning and vendor clustering
CREATE OR REPLACE TABLE `eastern-amp-449614-e1.yellow_taxi_dataset.optimized_yellow_taxi_data`
PARTITION BY DATE(tpep_dropoff_datetime)
CLUSTER BY VendorID AS
SELECT * FROM `eastern-amp-449614-e1.yellow_taxi_dataset.regular_yellow_taxi_data`;

-- Compare query performance for vendor analysis (regular vs optimized table)
SELECT DISTINCT VendorID
FROM `eastern-amp-449614-e1.yellow_taxi_dataset.regular_yellow_taxi_data`
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';

SELECT DISTINCT VendorID
FROM `eastern-amp-449614-e1.yellow_taxi_dataset.optimized_yellow_taxi_data`
WHERE tpep_dropoff_datetime BETWEEN '2024-03-01' AND '2024-03-15';

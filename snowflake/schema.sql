#Snowflake Schema for U.S. Economic Opportunity Index

#Step 1: Create a new database
CREATE OR REPLACE DATABASE economic_index_db;

#Step 2: Use the database
USE DATABASE economic_index_db;

#Step 3: Create a schema (optional but clean)
CREATE OR REPLACE SCHEMA opportunity_schema;

#Step 4: Use the schema
USE SCHEMA opportunity_schema;

#Step 5: Create your destination table
CREATE OR REPLACE TABLE opportunity_index (
    state STRING,
    date DATE,
    unemployment_rate DOUBLE,
    business_apps BIGINT,
    total_ev_stations BIGINT,
    opportunity_score DOUBLE
);
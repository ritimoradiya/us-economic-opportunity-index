
#SECTION 1: Create Cleaned Tables

#The raw datasets were cleaned and standardized in Alteryx Designer:
#2. Cleaned_ev_Final.csv   → EV Charging Stations
#3. Cleaned_unemployed_Final.csv → Unemployment Rates

#These files were uploaded to Databricks Volumes (economic_opportunity_data) and registered as tables.

CREATE OR REPLACE TABLE cleaned_bfs_final
USING CSV
OPTIONS (
  path "/Volumes/workspace/default/economic_opportunity_data/Cleaned_bfs_Final.csv",
  header "true",
  inferSchema "true"
);

CREATE OR REPLACE TABLE cleaned_ev_final
USING CSV
OPTIONS (
  path "/Volumes/workspace/default/economic_opportunity_data/Cleaned_ev_Final.csv",  
  header "true",
  inferSchema "true"
);

CREATE OR REPLACE TABLE cleaned_unemployed_final
USING CSV
OPTIONS (
  path "/Volumes/workspace/default/economic_opportunity_data/Cleaned_unemployed_Final.csv",
  header "true",
  inferSchema "true"
);


#SECTION 2: Join

CREATE OR REPLACE TABLE economic_opportunity_combined AS
SELECT
    bfs.State,
    bfs.date,
    bfs.business_apps,
    COALESCE(ev.total_ev_stations, 0) AS total_ev_stations,
    COALESCE(unem.unemployment_rate, 0) AS unemployment_rate
FROM cleaned_bfs_final bfs
LEFT JOIN cleaned_ev_final ev
    ON bfs.State = ev.State
LEFT JOIN cleaned_unemployed_final unem
    ON bfs.State = unem.State
    AND bfs.date = unem.date;


#SECTION 3: Normalize

CREATE OR REPLACE TABLE economic_opportunity_normalized AS
SELECT *,
    (business_apps - min_ba) / NULLIF((max_ba - min_ba), 0) AS normalized_business_apps,
    (total_ev_stations - min_ev) / NULLIF((max_ev - min_ev), 0) AS normalized_ev_stations
FROM (
    SELECT *,
        MIN(business_apps) OVER () AS min_ba,
        MAX(business_apps) OVER () AS max_ba,
        MIN(total_ev_stations) OVER () AS min_ev,
        MAX(total_ev_stations) OVER () AS max_ev
    FROM economic_opportunity_combined
);


#SECTION 4: Opportunity Score

CREATE OR REPLACE TABLE us_economic_opportunity_index AS
SELECT *,
    ((1 - unemployment_rate) * 0.4) +
    (normalized_business_apps * 0.3) +
    (normalized_ev_stations * 0.3) AS opportunity_score
FROM economic_opportunity_normalized;

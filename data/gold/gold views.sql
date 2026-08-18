

/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_races
-- =============================================================================
IF OBJECT_ID('gold.dim_races', 'V') IS NOT NULL
    DROP VIEW gold.dim_races;
GO

CREATE VIEW gold.dim_races AS
SELECT
    season
    ,round
    ,race_name
    ,race_date
    ,ci.circuit_name
    ,ci.locality
    ,ci.country
FROM silver.races AS rs
    JOIN silver.circuits AS ci
    ON rs.circuit_id = ci.circuit_id
GO

-- =============================================================================
-- Create Dimension: gold.dim_constructors
-- =============================================================================
IF OBJECT_ID('gold.dim_constructors', 'V') IS NOT NULL
    DROP VIEW gold.dim_constructors;
GO

CREATE VIEW gold.dim_constructors AS
SELECT
    constructor_id
    ,constructor_name
    ,nationality
FROM silver.constructor 
GO

-- =============================================================================
-- Create Dimension: gold.dim_drivers
-- =============================================================================
IF OBJECT_ID('gold.dim_drivers', 'V') IS NOT NULL
    DROP VIEW gold.dim_drivers;
GO

CREATE VIEW gold.dim_drivers AS
SELECT
    driver_id
    ,driver_name
    ,date_of_birth
    ,nationality
FROM silver.drivers 
GO

-- =============================================================================
-- Create Fact Table: gold.fact_session_results
-- =============================================================================
IF OBJECT_ID('gold.fact_session_results', 'V') IS NOT NULL
    DROP VIEW gold.fact_session_results;
GO

CREATE VIEW gold.fact_session_results AS
SELECT
    season
    ,round
    ,'race' AS session_type
    ,constructor_id
    ,driver_id
    ,grid_position
    ,completed_laps
    ,car_number
    ,points
    ,final_position
    ,final_position_text
    ,status
    ,CASE
        WHEN final_position = 1
            THEN 1
        ELSE 0
    END AS is_win
    ,CASE
        WHEN final_position IN (1,2,3)
            THEN 1
        ELSE 0
    END AS is_podium
    ,CASE
        WHEN points > 0
            THEN 1
        ELSE 0
    END AS has_points
FROM silver.results

UNION ALL

SELECT
    season
    ,round
    ,'sprints' AS session_type
    ,constructor_id
    ,driver_id
    ,grid_position
    ,completed_laps
    ,car_number
    ,points
    ,final_position
    ,final_position_text
    ,status
    ,CASE
        WHEN final_position = 1
            THEN 1
        ELSE 0
    END AS is_win
    ,CASE
        WHEN final_position IN (1,2,3)
            THEN 1
        ELSE 0
    END AS is_podium
    ,CASE
        WHEN points > 0
            THEN 1
        ELSE 0
    END AS has_points
FROM silver.sprints;
 
GO
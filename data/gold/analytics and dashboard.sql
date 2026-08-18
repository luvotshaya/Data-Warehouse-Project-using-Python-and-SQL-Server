
/*
===============================================================================
DDL Script: Create Analytics Views
===============================================================================
Script Purpose:
    This script creates views for the dashboard.

Usage:
    - These views can be queried directly for analytics and dashboard reporting.
===============================================================================
*/



-- =============================================================================
-- Create Analytical view: gold.uv_drivers_standing
-- =============================================================================
IF OBJECT_ID('gold.uv_drivers_standing', 'V') IS NOT NULL
    DROP VIEW gold.uv_drivers_standing;
GO

CREATE VIEW gold.uv_drivers_standing AS

SELECT
	season
	,r.driver_id
	,d.driver_name
	,nationality
	,COUNT(*) AS race_stats
	,SUM(r.points) AS total_points
	,SUM(r.is_win) AS number_of_wins
	,SUM(r.is_podium) AS number_of_podiums
	,ROW_NUMBER() OVER (
						PARTITION BY season 
						ORDER BY SUM(r.points) DESC
						,SUM(r.is_win) DESC
						,SUM(r.is_podium) DESC) AS standing_point
FROM gold.fact_session_results AS r
	JOIN gold.dim_drivers AS d
		ON d.driver_id = r.driver_id
GROUP BY season
	,r.driver_id
	,d.driver_name
	,nationality
GO

-- =============================================================================
-- Create Analytical view: gold.uv_constructors_standing
-- =============================================================================
IF OBJECT_ID('gold.uv_constructors_standing', 'V') IS NOT NULL
    DROP VIEW gold.uv_constructors_standing;
GO

CREATE VIEW gold.uv_constructors_standing AS

SELECT
	season
	,r.constructor_id
	,c.constructor_name
	,nationality
	,COUNT(*) AS race_stats
	,SUM(r.points) AS total_points
	,SUM(r.is_win) AS number_of_wins
	,SUM(r.is_podium) AS number_of_podiums
	,ROW_NUMBER() OVER (
						PARTITION BY season 
						ORDER BY SUM(r.points) DESC
						,SUM(r.is_win) DESC
						,SUM(r.is_podium) DESC) as standing_point
FROM gold.fact_session_results AS r
	JOIN gold.dim_constructors AS c
		ON c.constructor_id = r.constructor_id
GROUP BY season
		,r.constructor_id
		,c.constructor_name
		,nationality
GO


-- =============================================================================
-- Create Analytical view: gold.uv_drivers_of_all_times
-- =============================================================================

IF OBJECT_ID('gold.uv_drivers_of_all_times', 'V') IS NOT NULL
    DROP VIEW gold.uv_drivers_of_all_times;
GO

CREATE VIEW gold.uv_drivers_of_all_times AS

WITH CTE_greatest_driver AS(
SELECT 
	driver_name
	,SUM(race_stats) AS race_stats
	,SUM(number_of_wins) AS total_wins
	,SUM(number_of_podiums) AS total_podiums
	,SUM(CASE WHEN standing_point = 1 THEN 1 ELSE 0 END) AS total_champoinships
FROM gold.uv_drivers_standing
GROUP BY driver_name
HAVING SUM(CASE WHEN standing_point = 1 THEN 1 ELSE 0 END) >= 1
)

SELECT 
	driver_name
	,race_stats
	,total_wins
	,total_podiums
	,total_champoinships
	,(total_champoinships * 100) +(total_wins * 10)+ (total_podiums * 3) AS greatest_score
FROM CTE_greatest_driver
GO
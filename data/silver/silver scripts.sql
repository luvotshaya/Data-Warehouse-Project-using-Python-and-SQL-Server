USE [dbFormula1DE]
GO

/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

--CREATE SCHEMA silver
--GO

IF OBJECT_ID('silver.circuits', 'U') IS NOT NULL
    DROP TABLE silver.circuits;
GO

CREATE TABLE silver.circuits (
    circuit_id         NVARCHAR(50),
    circuit_name       NVARCHAR(50),
    latitude		   DECIMAL(8,6),
    longitude		   DECIMAL(8,6),
    locality		   NVARCHAR(50),
    country            NVARCHAR(50),
    source			   NVARCHAR(255),
    import_date        DATETIME
) 
GO

IF OBJECT_ID('silver.constructor', 'U') IS NOT NULL
    DROP TABLE silver.constructor;
GO

CREATE TABLE silver.constructor (
    constructor_id         NVARCHAR(50),
    constructor_name       NVARCHAR(50),
    nationality			   NVARCHAR(50),
    source			       NVARCHAR(255),
    import_date            DATETIME
) 
GO

IF OBJECT_ID('silver.drivers', 'U') IS NOT NULL
    DROP TABLE silver.drivers;
GO
CREATE TABLE silver.drivers (
    driver_id			   NVARCHAR(50),
    driver_name       NVARCHAR(50),
	date_of_birth		   DATE,
    nationality			   NVARCHAR(50),
    source			       NVARCHAR(255),
    import_date            DATETIME
) 
GO

IF OBJECT_ID('silver.races', 'U') IS NOT NULL
    DROP TABLE silver.races;
GO

CREATE TABLE silver.races (
    season			       INT,
    round                  INT,
	race_name			   NVARCHAR(50),
    race_date			   DATE,
	circuit_id			   NVARCHAR(50),
    source			       NVARCHAR(255),
    import_date            DATETIME
) 
GO

IF OBJECT_ID('silver.results', 'U') IS NOT NULL
    DROP TABLE silver.results;
GO

CREATE TABLE silver.results(
			season					INT
			,round					INT
			,constructor_id			NVARCHAR(50)
			,driver_id				NVARCHAR(50)
			,race_date				DATE
			,race_name				NVARCHAR(50)
			,grid_position			INT
			,completed_laps			INT
			,car_number				INT
			,points					INT
			,final_position			INT
			,final_position_text	CHAR(3)
			,status					NVARCHAR(50)
			,source					NVARCHAR(225)
			,import_date			DATETIME
)
GO

IF OBJECT_ID('silver.sprints', 'U') IS NOT NULL
    DROP TABLE silver.sprints;
GO

CREATE TABLE silver.sprints(
			season					INT
			,round					INT
			,constructor_id			NVARCHAR(50)
			,driver_id				NVARCHAR(50)
			,race_date				DATE
			,race_name				NVARCHAR(50)
			,grid_position			INT
			,completed_laps			INT
			,car_number				INT
			,points					INT
			,final_position			INT
			,final_position_text	CHAR(3)
			,status					NVARCHAR(50)
			,source					NVARCHAR(225)
			,import_date			DATETIME
)
GO
/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================

===============================================================================
*/
CREATE OR ALTER PROCEDURE silver.load_silver
AS

BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME; 
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		
		SET @start_time = GETDATE();

		CREATE TABLE #temp_results(
			season					INT
			,round					INT
			,constructor_id			NVARCHAR(50)
			,driver_id				NVARCHAR(50)
			,race_date				DATE
			,race_name				NVARCHAR(50)
			,grid_position			INT
			,completed_laps			INT
			,car_number				INT
			,points					INT
			,final_position			INT
			,final_position_text	CHAR(3)
			,status					NVARCHAR(50)
			,source					NVARCHAR(225)
			,import_date			DATETIME
		);

		CREATE TABLE #temp_sprints(
			season					INT
			,round					INT
			,constructor_id			NVARCHAR(50)
			,driver_id				NVARCHAR(50)
			,race_date				DATE
			,race_name				NVARCHAR(50)
			,grid_position			INT
			,completed_laps			INT
			,car_number				INT
			,points					INT
			,final_position			INT
			,final_position_text	CHAR(3)
			,status					NVARCHAR(50)
			,source					NVARCHAR(225)
			,import_date			DATETIME
		);
	
		
		IF EXISTS (SELECT 1 FROM silver.circuits)
		BEGIN
			TRUNCATE TABLE silver.circuits;
			PRINT '>> Truncating Table: silver.circuits';
		END
        
		PRINT '>> Inserting Data Into: silver.circuits';
		INSERT INTO silver.circuits (
			circuit_id
			,circuit_name       
			,latitude		   
			,longitude		   
			,locality		   
			,country           
			,source			  
			,import_date

			)

			SELECT
				circuitID AS circuit_id
				,bronze.CapitalizedText(circuitName) AS circuit_name
				,CASE 
					WHEN TRY_CAST(lat AS NUMERIC(8, 6)) IS  NOT NULL
						THEN CAST(lat AS NUMERIC(8, 6)) 
						ELSE 0
					END AS latitude
				,CASE 
					WHEN TRY_CAST(long AS NUMERIC(8, 6)) IS  NOT NULL
						THEN CAST(long AS NUMERIC(8, 6)) 
						ELSE 0
					END AS longitude 
				,bronze.CapitalizedText(locality) AS locality
				,country
				,source
				,import_date
			FROM bronze.circuits
			WHERE circuitID IS NOT NULL
			GROUP BY
				circuitID
				,bronze.CapitalizedText(circuitName)
				,CASE 
					WHEN TRY_CAST(lat AS NUMERIC(8, 6)) IS  NOT NULL
						THEN CAST(lat AS NUMERIC(8, 6)) 
						ELSE 0
					END 
				,CASE 
					WHEN TRY_CAST(long AS NUMERIC(8, 6)) IS  NOT NULL
						THEN CAST(long AS NUMERIC(8, 6)) 
						ELSE 0
					END 
				,bronze.CapitalizedText(locality)
				,country
				,source
				,import_date;

			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';

			SET @start_time = GETDATE();

			IF EXISTS (SELECT 1 FROM silver.constructor)
			BEGIN
				TRUNCATE TABLE silver.constructor;
				PRINT '>> Truncating Table: silver.constructor';
			END
			PRINT '>> Inserting Data Into: silver.constructor';
			INSERT INTO silver.constructor(
				constructor_id
				,constructor_name
				,nationality
				,source
				,import_date
			)

			SELECT
				constructorID AS constructor_id
				,name AS constructor_name
				,nationality
				,source
				,import_date
			FROM bronze.constructor
			WHERE constructorID IS NOT NULL;

			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';

			IF EXISTS (SELECT 1 FROM silver.drivers)
			BEGIN
				TRUNCATE TABLE silver.drivers;
				PRINT '>> Truncating Table: silver.drivers';
			END
			SET @start_time = GETDATE();

			PRINT '>> Inserting Data Into: silver.drivers table';

			INSERT INTO silver.drivers(
				driver_id
				,driver_name
				,date_of_birth
				,nationality
				,source
				,import_date
			)

			SELECT 
				driverId
				,bronze.CapitalizedText(CONCAT(givenName, ' ', familyName)) AS driver_name
				,dateOfBirth
				,nationality
				,source
				,import_date
			FROM bronze.drivers

			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';

			IF EXISTS (SELECT 1 FROM silver.races)
			BEGIN
				TRUNCATE TABLE silver.races;
				PRINT '>> Truncating Table: silver.races';
			END
			SET @start_time = GETDATE();

			PRINT '>> Inserting Data Into: silver.races table';
			INSERT INTO silver.races(
						season
						,round
						,race_name
						,race_date
						,circuit_id
						,source
						,import_date
			)

			SELECT 
				season
				,round
				,raceName
				,date
				,circuitID
				,source
				,import_date
			FROM bronze.races
			GROUP BY season
				,round
				,raceName
				,date
				,circuitID
				,source
				,import_date

			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';
			SET @start_time = GETDATE();

			INSERT INTO #temp_results(
				season					
				,round					
				,constructor_id			
				,driver_id				
				,race_date				
				,race_name				
				,grid_position			
				,completed_laps			
				,car_number				
				,points					
				,final_position			
				,final_position_text	
				,status					
				,source					
				,import_date			
			)
			SELECT
				season
				,round
				,constructorId
				,driverId
				,date
				,raceName
				,grid
				,laps
				,number
				,points
				,position
				,positionText
				,status
				,source
				,import_date
			FROM bronze.results;

			DELETE FROM #temp_results
			WHERE season IS NULL;

			DELETE FROM #temp_results
			WHERE round IS NULL;

			WITH CTE_Duplicates AS (
				SELECT 
					season
					,round
					,constructor_Id
					,driver_Id
					,ROW_NUMBER() OVER (
						PARTITION BY season
									,round
									,constructor_Id
									,driver_Id 
						ORDER BY season, round 
					) AS RowNum
				FROM #temp_results
			)
			DELETE FROM CTE_Duplicates
			WHERE RowNum > 1;

			IF EXISTS (SELECT 1 FROM silver.results)
			BEGIN
				TRUNCATE TABLE silver.results;
				PRINT '>> Truncating Table: silver.results';
			END

			PRINT '>> Inserting Data Into: silver.drivers table';

			INSERT INTO silver.results(
				season					
				,round					
				,constructor_id			
				,driver_id				
				,race_date				
				,race_name				
				,grid_position			
				,completed_laps			
				,car_number				
				,points					
				,final_position			
				,final_position_text	
				,status					
				,source					
				,import_date			
			)
			SELECT
				season					
				,round					
				,constructor_id			
				,driver_id				
				,race_date				
				,race_name				
				,grid_position			
				,completed_laps			
				,car_number				
				,points					
				,final_position			
				,final_position_text	
				,status					
				,source					
				,import_date
			FROM #temp_results;

			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';

			INSERT INTO #temp_sprints(
				season					
				,round					
				,constructor_id			
				,driver_id				
				,race_date				
				,race_name				
				,grid_position			
				,completed_laps			
				,car_number				
				,points					
				,final_position			
				,final_position_text	
				,status					
				,source					
				,import_date			
			)
			SELECT
				season
				,round
				,constructorId
				,driverId
				,date
				,raceName
				,grid
				,laps
				,number
				,points
				,position
				,positionText
				,status
				,source
				,import_date
			FROM bronze.sprints;

			DELETE FROM #temp_sprints
			WHERE season IS NULL;

			DELETE FROM #temp_sprints
			WHERE round IS NULL;

			WITH CTE_SpintsDuplicates AS (
				SELECT 
					season
					,round
					,constructor_Id
					,driver_Id
					,ROW_NUMBER() OVER (
						PARTITION BY season
									,round
									,constructor_Id
									,driver_Id 
						ORDER BY season, round 
					) AS RowNum
				FROM #temp_sprints
			)
			DELETE FROM CTE_SpintsDuplicates
			WHERE RowNum > 1;

			IF EXISTS (SELECT 1 FROM silver.sprints)
			BEGIN
				TRUNCATE TABLE silver.sprints;
				PRINT '>> Truncating Table: silver.sprints';
			END

			SET @start_time = GETDATE();
			PRINT '>> Truncating Table: silver.sprints';

			INSERT INTO silver.sprints(
				season					
				,round					
				,constructor_id			
				,driver_id				
				,race_date				
				,race_name				
				,grid_position			
				,completed_laps			
				,car_number				
				,points					
				,final_position			
				,final_position_text	
				,status					
				,source					
				,import_date			
			)
			SELECT
				season					
				,round					
				,constructor_id			
				,driver_id				
				,race_date				
				,race_name				
				,grid_position			
				,completed_laps			
				,car_number				
				,points					
				,final_position			
				,final_position_text	
				,status					
				,source					
				,import_date
			FROM #temp_sprints;

			SET @end_time = GETDATE();
			PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';
			PRINT '>> -------------';

			SET @batch_end_time = GETDATE();
			PRINT '=========================================='
			PRINT 'Loading Silver Layer is Completed';
			PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
			PRINT '=========================================='

    END TRY
	BEGIN CATCH
		PRINT '=========================================='
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
		PRINT 'Error Message' + ERROR_MESSAGE();
		PRINT 'Error Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '=========================================='
	END CATCH
END;
GO
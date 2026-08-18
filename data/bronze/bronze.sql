/*
=============================================================
Create Objects for the bronze layer
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

-- 1. Create the table under the specified schema
IF OBJECT_ID(N'bronze.circuits', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.circuits (
        circuitID      VARCHAR(50),
        url            VARCHAR(255),
        circuitName    VARCHAR(50),
        lat            DECIMAL(8, 8),
        long           DECIMAL(8, 8),
        locality       VARCHAR(50),
        country        VARCHAR(50),
        import_date    DATETIME,
        source         VARCHAR(255)
    );
    PRINT 'Table created successfully.';
END
ELSE
BEGIN
    PRINT 'Table already exists.';
END;
GO

-- 2. Create the table under the specified schema
IF OBJECT_ID(N'bronze.constructor', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.constructor (
        constructorID       VARCHAR(50),
        name                VARCHAR(50),
        nationality         VARCHAR(50),
        url                 VARCHAR(255),
        import_date         DATETIME,
        source              VARCHAR(255)
    );
    PRINT 'Table created successfully.';
END
ELSE
BEGIN
    PRINT 'Table already exists.';
END;
GO

-- 3. Create the table under the specified schema
IF OBJECT_ID(N'bronze.sprints', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.sprints (
        date                DATE,
        racename            VARCHAR(50),
        round               INT,
        season              INT,
        url                 VARCHAR(255),
        constructorId       VARCHAR(50),
        driverId            VARCHAR(50),
        grid                INT,
        laps                INT,
        number              INT,
        points              DECIMAL(3,2),
        position            INT,
        positionText        CHAR(2),
        status              VARCHAR(25),
        import_date         DATETIME,
        source              VARCHAR(255)
    );
    PRINT 'Table created successfully.';
END
ELSE
BEGIN
    PRINT 'Table already exists.';
END;
GO

-- 4. Create the table under the specified schema
IF OBJECT_ID(N'bronze.drivers', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.drivers (
        driverId            VARCHAR(50),
        dateOfBirth         DATE,
        nationality         VARCHAR(50),
        url                 VARCHAR(255),
        givenName           VARCHAR(50),
        familyName          VARCHAR(50),
        import_date         DATETIME,
        source              VARCHAR(255)
    );
    PRINT 'Table created successfully.';
END
ELSE
BEGIN
    PRINT 'Table already exists.';
END;
GO

-- 5. Create the table under the specified schema
IF OBJECT_ID(N'bronze.races', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.races (
        season              INT,
        round               INT,
        url                 VARCHAR(255),
        raceName            VARCHAR(50),
        date                DATE,
        circuitID           VARCHAR(50),
        import_date         DATETIME,
        source              VARCHAR(255)
    );
    PRINT 'Table created successfully.';
END
ELSE
BEGIN
    PRINT 'Table already exists.';
END;
GO

-- 6. Create the table under the specified schema
IF OBJECT_ID(N'bronze.results', N'U') IS NULL
BEGIN
    CREATE TABLE bronze.results (
        date                DATE,
        raceName            VARCHAR(50),
        round               INT,
        season              INT,
        url                 VARCHAR(255),
        constructorId       VARCHAR(50),
        driverId            VARCHAR(50),
        grid                INT,
        laps                INT,
        number              INT,
        points              INT,
        position            INT,
        positionText        CHAR(2),
        status              VARCHAR(50),
        import_date         DATETIME,
        source              VARCHAR(255)
    );
    PRINT 'Table created successfully.';
END
ELSE
BEGIN
    PRINT 'Table already exists.';
END;
GO

CREATE OR ALTER PROCEDURE bronze.delete_circuits
AS
BEGIN
    TRUNCATE TABLE bronze.circuits
END;
GO

CREATE OR ALTER PROCEDURE bronze.delete_constructor
AS
BEGIN
    TRUNCATE TABLE bronze.constructor
END;
GO

CREATE OR ALTER PROCEDURE bronze.delete_sprints
AS
BEGIN
    TRUNCATE TABLE bronze.sprints
END;
GO

CREATE OR ALTER PROCEDURE bronze.delete_results
AS
BEGIN
    TRUNCATE TABLE bronze.results
END;
GO

CREATE OR ALTER PROCEDURE bronze.delete_races
AS
BEGIN
    TRUNCATE TABLE bronze.races
END;
GO

CREATE OR ALTER PROCEDURE bronze.delete_drivers
AS
BEGIN
    TRUNCATE TABLE bronze.drivers
END;
GO

-- MySQL.sql
-- MySQL queries for crime data analysis
-- Author: Barbara
-- Dataset: Crime Data from Los Angeles Police Department
-- Description: Creates crimedb, loads crime CSV data, and runs 3 queries

-- Create database and table
CREATE DATABASE IF NOT EXISTS crimedb;
USE crimedb;

CREATE TABLE crimes (
    DR_NO VARCHAR(20),
    Date_Rptd VARCHAR(30),
    Date_OCC VARCHAR(30),
    Time_OCC VARCHAR(10),
    Area_ID VARCHAR(5),
    Area_Name VARCHAR(50),
    Rpt_Dist_No VARCHAR(10),
    Part_1_2 VARCHAR(5),
    Crm_Cd VARCHAR(10),
    Crm_Cd_Desc VARCHAR(100),
    Mocodes VARCHAR(100),
    Vict_Age VARCHAR(5),
    Vict_Sex VARCHAR(5),
    Vict_Descent VARCHAR(5),
    Premis_Cd VARCHAR(10),
    Premis_Desc VARCHAR(100),
    Weapon_Used_Cd VARCHAR(10),
    Weapon_Desc VARCHAR(100),
    Status VARCHAR(10),
    Status_Desc VARCHAR(50),
    Crm_Cd_1 VARCHAR(10),
    Crm_Cd_2 VARCHAR(10),
    Crm_Cd_3 VARCHAR(10),
    Crm_Cd_4 VARCHAR(10),
    Location VARCHAR(100),
    Cross_Street VARCHAR(100),
    LAT VARCHAR(20),
    LON VARCHAR(20)
);

-- Load data from CSV file
LOAD DATA LOCAL INFILE '/home/hduser/Downloads/Crime_Data.csv'
INTO TABLE crimes
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM crimes;

-- Query 1: Total crimes per year
SELECT
  SUBSTRING(Date_OCC, 7, 4) AS Year,
  COUNT(*) AS Total_Crimes
FROM crimes
WHERE Date_OCC != ''
GROUP BY Year
ORDER BY Year ASC;

-- Query 2: Top 10 crime locations
SELECT Premis_Desc, COUNT(*) AS Total_Crimes
FROM crimes
WHERE Premis_Desc != ''
GROUP BY Premis_Desc
ORDER BY Total_Crimes DESC
LIMIT 10;

-- Query 3: Top 10 crime types
SELECT Crm_Cd_Desc, COUNT(*) AS Occurrences
FROM crimes
WHERE Date_OCC != ''
GROUP BY Crm_Cd_Desc
ORDER BY Occurrences DESC
LIMIT 10;
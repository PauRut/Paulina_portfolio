#US Household Income Data Cleaning

## 1. Identify duplicates with COUNT function in two tables

SELECT id, COUNT(id) 
FROM us_household_income
GROUP BY id
HAVING COUNT(id) > 1;


SELECT id, COUNT(id) 
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(id) > 1;

## Identify duplicates with window functions

SELECT *
FROM (
SELECT row_id, id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
FROM us_household_income
) AS duplicates
WHERE row_num >1;

## 2. Delete duplicates
DELETE FROM us_household_income
WHERE id IN (
    SELECT id
    FROM (
        SELECT id, 
               ROW_NUMBER() OVER (PARTITION BY id ORDER BY id) AS row_num
        FROM us_household_income
    ) AS row_table
    WHERE row_num > 1
);

#Standarize values in State_Name column - there is one mispelling and "Alabama" written with lower case

SELECT  State_Name, Count(State_Name)
FROM US_Household_Income
GROUP BY  State_Name;

SELECT DISTINCT State_Name
FROM US_Household_Income
GROUP BY  State_Name;

SELECT State_Name
FROM US_Household_Income
WHERE State_name = 'georia';

UPDATE US_Household_Income
SET State_name = 'Alabama'
WHERE State_name = 'alabama';


#Populate fields with NULL values in Column Place
SELECT *
FROM US_Household_Income
WHERE Place IS NULL;

SELECT *
FROM US_Household_Income
WHERE City = 'Vinemont';

UPDATE US_Household_Income
SET Place = 'Autaugaville'
WHERE Place IS NULL;
 
# Does zip_code's length is 4 or 5
SELECT zip_code, LENGTH(zip_code)
FROM US_Household_Income
WHERE LENGTH(zip_code) < 4 AND LENGTH(zip_code) > 5;

#Check if fields have NULL or no values
SELECT *
FROM US_Household_Income
WHERE Area_Code IS NULL OR Area_Code = 0 OR Area_Code = "";


#Check if there is any misspeling / 'Boroughs' change to 'Borough' and  CPD to CDP
SELECT COUNT(type), type 
FROM US_Household_Income
GROUP BY type;

UPDATE US_Household_Income
SET type = "CDP"
WHERE type = "CPD";

UPDATE US_Household_Income
SET type = "Borough"
WHERE type = "Boroughs";


#Check if there is NULLS, blank or 0 values in AWater and ALand

SELECT ALand, AWater
FROM US_Household_Income
WHERE (ALand IS NULL OR ALand = 0 OR ALand = "")
AND (AWater IS NULL OR AWater = 0 OR AWater = "");

SELECT ALand, AWater
FROM US_Household_Income
WHERE AWater IS NULL OR AWater = 0 OR AWater = "";

#US Household Income (Exploratory Data Analysis)

# TOP 10 Largest States by land
SELECT  State_Name, SUM(ALand) AS Land
FROM US_Household_Income
GROUP BY State_Name
ORDER BY SUM(ALand) DESC
LIMIT 10;

# TOP 10 Largest States by Water
SELECT  State_Name, SUM(AWater) AS Water
FROM US_Household_Income
GROUP BY State_Name
ORDER BY SUM(AWater) DESC
LIMIT 10;


# 5 States with lowest average income for entire household 
SELECT hi.State_Name, AVG(mean) 
FROM US_Household_Income hi
JOIN us_household_income_statistics his
ON  hi.id = his.id
WHERE mean <> 0
GROUP BY hi.State_Name
ORDER BY 2
LIMIT 5;


# 5 States with highest average income for entire household 
SELECT hi.State_Name, AVG(mean) 
FROM US_Household_Income hi
JOIN us_household_income_statistics his
ON  hi.id = his.id
WHERE mean <> 0
GROUP BY hi.State_Name
ORDER BY 2 DESC
LIMIT 5;

# 10 Cities with highest average income for entire household 
SELECT hi.State_name, hi.City, ROUND(AVG(mean), 1)
FROM US_Household_Income hi
JOIN us_household_income_statistics his
ON  hi.id = his.id
GROUP BY hi.State_name, hi.City
ORDER BY  ROUND(AVG(mean), 1) DESC
LIMIT 10;





SELECT * FROM US_Household_Income;
SELECT * FROM us_household_income_statistics;


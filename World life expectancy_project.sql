#World Life Expectancy Project (Data Cleaning)

SELECT * FROM World_Life_Expectancy.world_life_expectancy;

## 1. Identify duplicates and delete them

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year)) AS concat_
FROM world_life_expectancy
GROUP BY Country, Year;                                                                                      

SELECT * FROM World_Life_Expectancy.world_life_expectancy;

## 1. Identify duplicates and delete them

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year)) AS concat_
FROM world_life_expectancy
GROUP BY Country, Year
HAVING concat_ >1;

## Identify row_ids of duplicates 
SELECT *
FROM (
	SELECT Row_Id, CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_numb
	FROM world_life_expectancy) AS Row_table
    WHERE Row_numb > 1;

## Delete 3 duplicates 

DELETE FROM world_life_expectancy
WHERE Row_id IN 
(SELECT Row_id
FROM (
	SELECT Row_Id, CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_numb
HAVING concat_ >1;

## Identify row_ids of duplicates 
SELECT *
FROM (
	SELECT Row_Id, CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_numb
	FROM world_life_expectancy) AS Row_table
    WHERE Row_numb > 1;

## Delete 3 duplicates 

DELETE FROM world_life_expectancy
WHERE Row_id IN 
(SELECT Row_id
FROM (
	SELECT Row_Id, CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_numb
	FROM world_life_expectancy) AS Row_table
    WHERE Row_numb > 1);

# 2. Identify unpopulated fields in column status and populate them

SELECT * FROM world_life_expectancy
WHERE Status = "";

SELECT DISTINCT(Status) 
FROM world_life_expectancy
WHERE Status <> "";

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE status = "Developing";

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.Status = "Developing"
WHERE t1.Status = ""
AND t2.Status <> ""
AND t2.Status = "Developing";

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.Status = "Developed"
WHERE t1.Status = ""
AND t2.Status <> ""
AND t2.Status = "Developed";

# 3. Identify unpopulated fields in column Life expectancy and populate them

SELECT * FROM world_life_expectancy
WHERE `Life expectancy` = '';

SELECT * FROM world_life_expectancy
WHERE country = "Afghanistan";


# Populate unpopulated fields in column Life expectancy by adding life expectancy from preview and next year and divide it by 2

SELECT t1.country, t1.Year, t1.`Life expectancy`, 
t2.country, t2.Year, t2.`Life expectancy`, 
t3.country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year + 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year - 1
WHERE t1.`Life expectancy` = '';


UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
    AND t1.year = t2.year + 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country
    AND t1.year = t3.year - 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ""
;

#World Life Expectancy Project (Exploratory Data Analysis)


#Check the highest and lowest life expectancy for each country and see the difference between the highest and lowest life expectancy between 2007 and 202
SELECT Country, MAX(`Life expectancy`) AS max_life_expectancy, 
MIN(`Life expectancy`) AS min_life_expectancy, 
ROUND((MAX(`Life expectancy`) - MIN(`Life expectancy`)), 2) AS life_increase_15_years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0
AND MAX(`Life expectancy`) <> 0
ORDER BY life_increase_15_years DESC;
#Conclusion: during 15 years (between 2007 and 2022) the life expectancy increased in some countries for over 20years! 

# Averege life expectancy for each year (excluding countries with 0 value in Life expectancy field)
SELECT Year, ROUND(AVG(`Life expectancy`),2) AS average_life_expectancy
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year DESC;
#Conclusion: during 15 years (between 2007 and 2022) the average life expectancy increased for almost 5 years


# Is there any correlation between GDP and Life expectancy?
SELECT Country, 
ROUND(AVG(`Life expectancy`),2) AS Avg_life_expectancy, 
ROUND(AVG(GDP),2) AS Avg_GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Avg_life_expectancy >  0 
AND Avg_GDP > 0
ORDER BY Avg_GDP DESC;

#GDP and life expectancy averages for the whole world
SELECT 
ROUND(AVG(GDP),1) AS avg_gdp, 
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy
FROM world_life_expectancy;


#GDP vs Life expectancy 
SELECT 
	SUM(CASE WHEN GDP >= 1200 THEN 1 ELSE 0 END) High_GDP_Count,
	AVG(CASE WHEN GDP >= 1200 THEN `Life expectancy` ELSE NULL END) High_GDP_Life_expectancy,
	SUM(CASE WHEN GDP <= 1200 THEN 1 ELSE 0 END) Low_GDP_Count,
	AVG(CASE WHEN GDP <= 1200 THEN `Life expectancy` ELSE NULL END) Low_GDP_Life_expectancy
FROM world_life_expectancy;
#Conclusion: Low GDP --> Lower life expectancy, High GDP --> higher life expectancy

# Average for life expectancy between developing and developed countries
SELECT status, 
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy, 
COUNT(DISTINCT country) AS count_countries
FROM world_life_expectancy
GROUP BY status;

# Average adult mortality vs average life expectancy for countries
SELECT COUNTRY, 
ROUND(AVG(`Adult Mortality`),1) AS avg_adult_mortality, 
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy
FROM world_life_expectancy
GROUP BY country
HAVING avg_adult_mortality <> 0
AND avg_life_expectancy <> 0
ORDER BY avg_adult_mortality ASC;

SELECT status, 
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy, 
ROUND(AVG(`Adult Mortality`),1) AS avg_adult_mortality
FROM world_life_expectancy
GROUP BY status;
#Conclusion: Lower adult mortality  --> Higher life expectancy, Higher adult mortality schooling --> lower life expectancy


# Schooling vs Life expectancy
SELECT DISTINCT(COUNTRY), 
ROUND(AVG(Schooling),1) as schooling,
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy
FROM world_life_expectancy
GROUP BY Country
HAVING schooling <> 0
ORDER BY schooling DESC;

SELECT status, 
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy, 
ROUND(AVG(Schooling),1) as schooling
FROM world_life_expectancy
GROUP BY status;
#Conclusion: Higher schooling  --> Higher life expectancy, Lower schooling --> lower life expectancy




# Percentage expenditure vs Life expectancy
SELECT
ROUND(AVG(`percentage expenditure`),1) as Percentage_expenditure,
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy
FROM world_life_expectancy;


SELECT country,
ROUND(AVG(`percentage expenditure`),1) as Percentage_expenditure,
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy
FROM world_life_expectancy
GROUP BY country
ORDER BY Percentage_expenditure DESC;

SELECT status, 
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy, 
ROUND(AVG(`percentage expenditure`),1) as Percentage_expenditure
FROM world_life_expectancy
GROUP BY status;
#Conclusion: Higher percentage expenditure  --> Higher life expectancy, Lower percentage expenditure --> lower life expectancy



# Percentage expenditure vs Life expectancy
SELECT
ROUND(AVG(`HIV/AIDS`),1) as HIV_AIDS,
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy
FROM world_life_expectancy;


SELECT country,
ROUND(AVG(`HIV/AIDS`),1) as HIV_AIDS,
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy
FROM world_life_expectancy
GROUP BY country
ORDER BY HIV_AIDS ASC;

SELECT status, 
ROUND(AVG(`Life expectancy`),1) AS avg_life_expectancy, 
ROUND(AVG(`HIV/AIDS`),1) as HIV_AIDS
FROM world_life_expectancy
GROUP BY status;
#Conclusion: Higher percentage of HIV/AIDS--> Lower life expectancy, Lower percentage of HIV/AIDS --> higher life expectancy

SELECT * FROM world_life_expectancy;


SELECT * FROM world_life_expectancy;


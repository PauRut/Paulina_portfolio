## REMOVING DUPLICATES

SELECT * 
FROM customer_sweepstakes;

## 1. Identify duplicates with COUNT function
SELECT customer_id, COUNT(customer_id)
FROM customer_sweepstakes
GROUP BY customer_id
HAVING COUNT(customer_id) > 1;

## Identify duplicates with window functions
SELECT * FROM(
SELECT customer_id, 
ROW_NUMBER() OVER (PARTITION BY customer_id order by customer_id) AS row_num
FROM customer_sweepstakes) as row_table
WHERE row_num >1;

## 2. Delete duplicates
DELETE FROM customer_sweepstakes
WHERE sweepstake_id IN (
    SELECT sweepstake_id
    FROM (
        SELECT sweepstake_id, 
               ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) AS row_num
        FROM customer_sweepstakes
    ) AS row_table
    WHERE row_num > 1
);

## STANDARAZING DATA

## 3. Deletaing special characters with Regular Expression
SELECT phone, REGEXP_REPLACE(phone, '[-()/]', '')
FROM customer_sweepstakes;

## 4. Update phone numbers with removing special characters
UPDATE  customer_sweepstakes
SET phone = REGEXP_REPLACE(phone, '[-()/]', '');


## 5. Standarize the format of phone numbers, adding '-'
## A. Concatenate 3 substrings
SELECT phone, CONCAT(SUBSTRING(phone,1,3), ' ', SUBSTRING(phone,4,3), ' ', SUBSTRING(phone,7,4))
FROM customer_sweepstakes
WHERE phone <> '';

## B. Update the column with new values
UPDATE customer_sweepstakes
SET phone = CONCAT(SUBSTRING(phone,1,3), '-', SUBSTRING(phone,4,3), '-', SUBSTRING(phone,7,4))
WHERE phone <> '';

## 6. Standarize the format of birth dates
SELECT birth_date, 
STR_TO_DATE(birth_date, '%m/%d/%Y'),
STR_TO_DATE(birth_date, '%Y/%d/%m')
FROM customer_sweepstakes;

## A. IF statement to populate birth data cells
SELECT birth_date, 
IF(STR_TO_DATE(birth_date, '%m/%d/%Y') IS NOT NULL, 
STR_TO_DATE(birth_date, '%m/%d/%Y'), 
STR_TO_DATE(birth_date, '%Y/%d/%m'))
FROM customer_sweepstakes;


## B. Update with IF statement
UPDATE customer_sweepstakes
SET birth_date = IF(STR_TO_DATE(birth_date, '%m/%d/%Y') IS NOT NULL, 
STR_TO_DATE(birth_date, '%m/%d/%Y'), 
STR_TO_DATE(birth_date, '%Y/%d/%m'));
## didnt work the upper update


## B  Update with CASE statement // didnt work the neighter
UPDATE customer_sweepstakes
SET birth_date = CASE 
WHEN STR_TO_DATE(birth_date, '%m/%d/%Y') IS NOT NULL THEN STR_TO_DATE(birth_date, '%m/%d/%Y')
WHEN STR_TO_DATE(birth_date, '%m/%d/%Y') IS NULL THEN STR_TO_DATE(birth_date, '%Y/%d/%m')
END;


## Format birth date by substring and concatenating //
UPDATE customer_sweepstakes
SET birth_date = CONCAT(SUBSTRING(birth_date, 9,2), '/', SUBSTRING(birth_date, 6,2), '/', SUBSTRING(birth_date, 1,4))
WHERE sweepstake_id IN (9,11);

## UPDATE birth dates /WORKED
UPDATE customer_sweepstakes
SET birth_date = STR_TO_DATE(birth_date, '%m/%d/%Y');

## 7. Standarize the `Are you over 18?` Column
##Change Column name
ALTER TABLE customer_sweepstakes RENAME COLUMN `Are you over 18?` TO over_18;

## Standarize the columns cells
SELECT over_18,
CASE 
WHEN over_18 = 'Yes' THEN 'Y'
WHEN over_18 = 'No' THEN 'N'
ELSE over_18
END
FROM customer_sweepstakes;


## Update columns cells
UPDATE customer_sweepstakes
SET over_18 = 
CASE 
WHEN over_18 = 'Yes' THEN 'Y'
WHEN over_18 = 'No' THEN 'N'
ELSE over_18
END;


## 8. Breaking Column into Multiple Columns
SELECT address, SUBSTRING_INDEX(address, ',',1) AS Street, 
SUBSTRING_INDEX(SUBSTRING_INDEX(address, ',',2), ',', -1) AS City,
(SUBSTRING_INDEX(address, ',',-1)) AS State, 
TRIM((SUBSTRING_INDEX(address, ',',-1)))
FROM customer_sweepstakes;

## Create new columns for Street, City and State and place it after address column
ALTER TABLE customer_sweepstakes 
ADD COLUMN street VARCHAR(50) AFTER address,
ADD COLUMN city VARCHAR(50) AFTER street,
ADD COLUMN state VARCHAR(2) AFTER city;

## UPDATE Street, city and state columns
UPDATE customer_sweepstakes
SET street = SUBSTRING_INDEX(address, ',',1);

UPDATE customer_sweepstakes
SET city  = SUBSTRING_INDEX(SUBSTRING_INDEX(address, ',',2), ',', -1); 

UPDATE customer_sweepstakes
SET state = SUBSTRING_INDEX(address, ',',-1); ## Doesnt work. Lenght is 3characters and not 2. I need to alter table 

##Change the length of the state column
ALTER TABLE customer_sweepstakes MODIFY COLUMN state VARCHAR(3);

## UPDATE state columns. This time works
UPDATE customer_sweepstakes
SET state = SUBSTRING_INDEX(address, ',',-1);

## UPDATE state column, standarize by adding UPPER
UPDATE customer_sweepstakes
SET state = UPPER(state);

## TRIM city and state column and update them
SELECT city, TRIM(city), state, TRIM(state)
FROM customer_sweepstakes;

UPDATE customer_sweepstakes
SET city =  TRIM(city);

UPDATE customer_sweepstakes
SET state =  TRIM(state);

##Change the length of the state column
ALTER TABLE customer_sweepstakes MODIFY COLUMN state VARCHAR(2);


##9. DELETE unnecessary columns
ALTER TABLE customer_sweepstakes
DROP COLUMN address;

ALTER TABLE customer_sweepstakes
DROP COLUMN favorite_color;

#10.a. 2 phone numbers have no values, are not NULL but blank. Update blank to null

UPDATE customer_sweepstakes
SET phone = NULL
WHERE phone = '';

#10.b. 2 income cells have no values, are not NULL but blank. Update blank to null

UPDATE customer_sweepstakes
SET income = NULL
WHERE income = '';

#11. There some errors in column over_18. I need to change "Y" to "N" for person born in 2006

SELECT birth_date, over_18
FROM customer_sweepstakes
WHERE (YEAR(NOW()) - 18) <= YEAR(birthworld_life_expectancy_date);

# Respond in over_18 column must be change from "Y" to "N" for person born in 2006
UPDATE customer_sweepstakes
SET over_18 = 'N'
WHERE (YEAR(NOW()) - 18) <= YEAR(birth_date);

# Respond in over_18 column must be change from "N" to "Y" for person born in 2001 and 1999
SELECT birth_date, over_18
FROM customer_sweepstakes
WHERE (YEAR(NOW()) - 18) > YEAR(birth_date);

UPDATE customer_sweepstakes
SET over_18 = 'Y'
WHERE (YEAR(NOW()) - 18) > YEAR(birth_date);


SELECT * 
FROM customer_sweepstakes;


/* WORLDWIDE LAYOFFS PROJECT*/
----- DATA PREPROCESSING -----

-- DATE: 2024-05-29 


SELECT *
  FROM layoffs

-- Evaluate for full duplicates
WITH
duplicate_cte AS (
SELECT *,
	   ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions) AS row_num
  FROM layoffs
)

SELECT *
  FROM duplicate_cte
 WHERE row_num > 1
;

WITH
duplicate_cte AS (
SELECT ctid,  -- Use ctid as the unique record identifier
   	   ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
						      ORDER BY ctid) AS row_num
 FROM layoffs
)

DELETE
  FROM layoffs
 WHERE ctid IN (SELECT ctid
    			  FROM duplicate_cte
    			 WHERE row_num > 1)
; -- 2 full duplicates were removed


-- Remove leading/trailing spaces from text fields
UPDATE layoffs
   SET company = TRIM(company),
   	   location = TRIM(location),
	   industry = TRIM(industry),
	   stage = TRIM(stage),
	   country = TRIM(country)
;


-- Standardizing 'location' field
SELECT DISTINCT location
  FROM layoffs
 ORDER BY 1
;

UPDATE layoffs
   SET location = 'Düsseldorf'
 WHERE location = 'Dusseldorf'
;

UPDATE layoffs
   SET location = 'Malmö'
 WHERE location = 'Malmo'
;


-- Standardizing 'country' field
SELECT DISTINCT country
  FROM layoffs
 ORDER BY 1
;

UPDATE layoffs
   SET country = TRIM(TRAILING '.' FROM country)
 WHERE country LIKE 'United States%'
;


-- Count null values in every column
SELECT COUNT(*) - COUNT(company) AS nulls_company,
	   COUNT(*) - COUNT(location) AS nulls_location,
	   COUNT(*) - COUNT(industry) AS nulls_industry,
	   COUNT(*) - COUNT(total_laid_off) AS nulls_total_laid_off,
	   COUNT(*) - COUNT(percentage_laid_off) AS nulls_percentage_laid_off,
	   COUNT(*) - COUNT(date) AS nulls_date,
	   COUNT(*) - COUNT(stage) AS nulls_stage,
	   COUNT(*) - COUNT(country) AS nulls_country,
	   COUNT(*) - COUNT(funds_raised_millions) AS nulls_funds_raised_millions
  FROM layoffs
; -- Since 'total_laid_off' & 'percentage_laid_off' fields are the primary focus of this analysis, any records without this data are irrelevant for this project

-- Remove records without 'total_laid_off' & 'percentage_laid_off' data
DELETE
  FROM layoffs
 WHERE total_laid_off IS NULL
   AND percentage_laid_off IS NULL
; -- 596 records were removed


-- Identify records where there are missing values in 'industry' and find the corresponsing non-missing values for the same 'company'
SELECT a.industry, b.industry
  FROM layoffs a
  JOIN layoffs b
  	   ON a.company = b.company
 WHERE a.industry IS NULL
   AND b.industry IS NOT NULL
; -- No records were found with the corresponding non-missing value for the null(s) identified


-- Identify records where there are missing values in 'location' and find the corresponsing non-missing values for the same 'company'
SELECT a.location, b.location
  FROM layoffs a
  JOIN layoffs b
  	   ON a.company = b.company
 WHERE a.location IS NULL
   AND b.location IS NOT NULL
; -- No records were found with the corresponding non-missing value for the null(s) identified


-- Identify records where there are missing values in 'stage' and find the corresponsing non-missing values for the same 'company'
SELECT a.stage, b.stage
  FROM layoffs a
  JOIN layoffs b
  	   ON a.company = b.company
 WHERE a.stage IS NULL
   AND b.stage IS NOT NULL
; -- No records were found with the corresponding non-missing value for the null(s) identified

/* WORLDWIDE LAYOFFS PROJECT */
-- EXPLORATORY DATA ANALYSIS --

-- DATE: 2024-05-30



-- Dataset timeframe
SELECT MIN(date) AS min_date,
	   MAX(date) AS max_date
  FROM layoffs
; -- The data availability is from when COVID-19 was declared as a pandemic (03/11/2020) to present (05/24/2024).


-- Layoff grand total
SELECT SUM(total_laid_off)
  FROM layoffs
; -- Over 600,000 people had lost their jobs worldwide from 2020 to 2024.


-- Layoff grand total by year
SELECT EXTRACT(YEAR FROM date) AS year, SUM(total_laid_off) AS layoff_grand_total
  FROM layoffs
 WHERE total_laid_off IS NOT NULL
   AND date IS NOT NULL
 GROUP BY 1
 ORDER BY 1 DESC
;

/* Layoff Trends (2020-2024) */
-- Layoffs peaked in 2023 with over 250,000 people losing their jobs. 
-- There was a significant drop in 2024, with about 90,000 layoffs in the first half of the year, indicating a downward trend.


-- Layoff grand total by company
SELECT company, SUM(total_laid_off) AS layoff_grand_total
  FROM layoffs
 WHERE total_laid_off IS NOT NULL
  -- AND date BETWEEN '2024-01-01' AND '2024-12-31'
 GROUP BY company
 ORDER BY layoff_grand_total DESC
;
-- Big tech companies were significantly impacted by layoffs. During this period, Amazon, Meta, and Google have experienced the highest number of layoffs.


-- Layoff grand total by industry
SELECT industry, SUM(total_laid_off) AS layoff_grand_total
  FROM layoffs
 WHERE total_laid_off IS NOT NULL
 GROUP BY industry
 ORDER BY layoff_grand_total DESC
; -- Consumer and retail industries experienced the highest number of layoffs during this period.


-- Layoff grand total by country
SELECT country, SUM(total_laid_off) AS layoff_grand_total
  FROM layoffs
 WHERE total_laid_off IS NOT NULL
 GROUP BY country
 ORDER BY layoff_grand_total DESC
;
-- Over time, the United States leads globally with over 400,000 layoffs, about 9 times more than India, which ranks second with just over 50,000 layoffs.

-- Calculate percentage of layoffs in the United States throughout the years
SELECT ROUND(((SELECT SUM(total_laid_off) 
			     FROM layoffs
			    WHERE country = 'United States') * 1.0 / (SELECT SUM(total_laid_off)
														    FROM layoffs)
			  ) * 100, 1)
; -- The United States has by far the highest number of layoffs during this period, making up about 70% of the total layoffs worlwide.


-- Monthly worlwide total layoffs & rolling total
WITH
monthly_layoffs AS (
SELECT EXTRACT(YEAR FROM date) AS year, EXTRACT(MONTH FROM date) AS month, SUM(total_laid_off) AS total_layoffs
  FROM layoffs
 WHERE date IS NOT NULL
 GROUP BY 1, 2
)

SELECT year, month, total_layoffs,
	   SUM(total_layoffs) OVER(ORDER BY year, month) AS total_layoffs
  FROM monthly_layoffs
 ORDER BY year, month
; 
-- Layoffs spiked in early 2020 due to COVID-19, stabilized in 2021, increased again in 2022, and peaked dramatically in early 2023.
-- In early 2024, layoffs dropped by about 60% compared to 2023, indicating a significant overall decrease.


-- Top 5 companies with highest layoffs by year
WITH
company_year_layoffs AS (
SELECT company, EXTRACT(YEAR FROM date) AS year, SUM(total_laid_off) AS total_layoffs
  FROM layoffs
 WHERE total_laid_off IS NOT NULL
   AND date IS NOT NULL
 GROUP BY 1, 2
),

company_year_rank AS (
SELECT company, year, total_layoffs,
	   DENSE_RANK() OVER(PARTITION BY year
						 	 ORDER BY total_layoffs DESC) AS ranking
  FROM company_year_layoffs
 ORDER BY ranking
)

SELECT *
  FROM company_year_rank
 WHERE ranking <= 5
 ORDER BY year, ranking
; -- Tech companies consistently have high layoffs throughout the years. Amazon stands out in 2023 with the highest laid off people across all companies during this period.
-- In the first half of 2024, Tesla leads with over 14,000 layoffs so far, which positions the company at 3rd place of total layoffs from 2020 to present.


-- Top 5 countries with highest layoffs by year
WITH
country_year_layoffs AS (
SELECT country, EXTRACT(YEAR FROM date) AS year, SUM(total_laid_off) AS total_layoffs
  FROM layoffs
 WHERE total_laid_off IS NOT NULL
   AND date IS NOT NULL
 GROUP BY 1, 2
),

country_year_rank AS (
SELECT country, year, total_layoffs,
	   DENSE_RANK() OVER(PARTITION BY year
						 	 ORDER BY total_layoffs DESC) AS ranking
  FROM country_year_layoffs
 ORDER BY ranking
)

SELECT *
  FROM country_year_rank
 WHERE ranking <= 5
 ORDER BY year, ranking
;
-- The United States consistently appears with the highest layoff numbers throughout the years, peaking significantly in 2023 with over 180,000 layoffs.
-- In the first half of 2024, the United States has the highest number of layoffs by far, followed by Germany, the UK, Japan, and India.


-- Top 5 US locations with highest layoffs by year
WITH
us_year_layoffs AS (
SELECT location, EXTRACT(YEAR FROM date) AS year, SUM(total_laid_off) AS total_layoffs
  FROM layoffs
 WHERE total_laid_off IS NOT NULL
   AND date IS NOT NULL
   AND country = 'United States'
 GROUP BY 1, 2
),

us_year_rank AS (
SELECT location, year, total_layoffs,
	   DENSE_RANK() OVER(PARTITION BY year
						 	 ORDER BY total_layoffs DESC) AS ranking
  FROM us_year_layoffs
 ORDER BY ranking
)

SELECT *
  FROM us_year_rank
 WHERE ranking <= 5
 ORDER BY year, ranking
;
-- The San Francisco Bay Area consistently had the highest number of layoffs, but in 2024, Austin, Texas took the lead with over 22,000 layoffs so far.
-- Other major cities like New York and Seattle have also been among the top 5 with the highest layoffs throughout the years.


-- Number of companies that went bankrupt by year (i.e., those that laid off 100% of their personnel)
SELECT EXTRACT(YEAR FROM date) AS year, COUNT(percentage_laid_off)
  FROM layoffs
 WHERE percentage_laid_off = 1
 GROUP BY year
; -- 2023 also experienced the highest number of companies that went bankrupt based on the fact that their entire personnel was laid off based on the data available. See query below for caveat.


-- Count of nulls in percentage_laid_off
SELECT SUM(CASE
	   	   WHEN percentage_laid_off IS NULL THEN 1
	   	    END) AS null_count
  FROM layoffs
; -- There is a significant proportion of missing values in the percentage_laid_off field, which could affect the accuracy of any calculations.

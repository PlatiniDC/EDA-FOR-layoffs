-- Exploratory Data Analysis
-- EDA is the process of using sql to investigate clean and summmarize 
-- a dataset to understand its main characteristics before performing 
-- more advanced modelling or statistical test.

SELECT *
FROM layoffs_staging2
;
-- the above is the cleaned data set from the world layoffs data.

-- looking at the max total laidoff in one day, see below

SELECT MAX(total_laid_off)
FROM layoffs_staging2
;
-- so on one particular day, there is a firm that has the total layoff of 12000 people. 

SELECT MAX(percentage_laid_off)
FROM layoffs_staging2
;
-- i also took a look at the max percentage laid off and it looks like 
-- some company folded by laying off all their staffs.
-- N:b when percentage gives result as 1 it means 100 percent.

-- exploring further, you can decide to see if there is any company you recognize and has already 
-- folded. And also check which had the most employees laid off.

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC
;

-- YOU CAN ALSO ORDER BY THEIR FUNDS RAISED IN MILION
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC
;

-- next is looking at each companies total laid off
-- this can be done using sum and group by And order by clause

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
;
-- The date range can also be explored using the min and max clause.

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2
;
-- this easily tells you the amount of people that was laid off within a specific period. 

-- just like we checked for companies, we can also check for industries that really got hit
-- with layoffs.

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
;

-- the country with highest laid offs

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
;

-- we can also look at the amount of people laid off in each year. 

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC
; 

-- The rolling total of people laid off each month can also be looked at
-- see below

SELECT SUBSTRING(`date` ,6,2) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`
;
-- But this is not a great rolling total because it shows just the month amd not the year.

SELECT SUBSTRING(`date` ,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
WHERE SUBSTRING(`date` ,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
;
-- The above shows the total lay offs each month starting from march 2020. 

-- To create a rolling total based on the month, i needed to use a CTE. 

WITH Rolling_total AS
(
SELECT SUBSTRING(`date` ,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
WHERE SUBSTRING(`date` ,1,7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off,
 SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
 FROM Rolling_total
 ;
 
 -- we can look at how much employees the company was laying off per year
 
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company ASC
;
-- The year most employees were laid off can also be Ranked using a cte

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC
;

-- see ranking below, so we get to see who laid off most employees per year.
WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
ORDER BY Ranking ASC
;

-- IN A CASE WHERE I WANT TO KNOW THE TOP 5 COMPANIES IN EACH YEAR
-- I WILL ADD ANOTHER CTE
-- SEE BELOW
-- see ranking below, so we get to see who laid off most employees per year.

WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5
;

-- a lot can actually be looked at when working on data sets, but that depends on what you are working on.


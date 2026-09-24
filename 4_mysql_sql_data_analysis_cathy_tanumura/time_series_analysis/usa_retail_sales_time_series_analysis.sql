/*
--------------------------------------------------------------------------------
PostgreSQL Date/Time Fundamentals + Retail Sales Analysis
Author: Teslim Adeyanju, ACA
Dialect: PostgreSQL 12+ (tested on 15/16)
Purpose: Handy reference for date/timestamp functions, date/time arithmetic,
         formatting, and retail_sales analytics with GROUP BY + window functions.
--------------------------------------------------------------------------------
*/

-- ============================================================================
-- 1) CURRENT DATE/TIME
-- ============================================================================

   -- Current date (DATE)
   SELECT 
         CURRENT_DATE AS CURRENT_DATE;
   -- Local timestamp (TIMESTAMP WITHOUT TIME ZONE)
   SELECT 
         LOCALTIMESTAMP AS local_ts;
   -- Current timestamp (TIMESTAMP WITH TIME ZONE)
   SELECT 
         CURRENT_TIMESTAMP AS current_timestamptz;
   -- NOW() is equivalent to current_timestamp in Postgres
   SELECT 
         NOW() AS now_timestamptz;
   -- Current time (TIME WITHOUT TIME ZONE)
   SELECT
         CURRENT_TIME AS CURRENT_TIME;
   -- Local time (TIME WITHOUT TIME ZONE)
   SELECT 
         LOCALTIME AS local_time;


-- ============================================================================
-- 2) TRUNCATING TIMESTAMPS
--    NOTE: date_trunc returns TIMESTAMP/TIMESTAMPTZ at the chosen precision.
--    Week truncation uses Monday as the first day of the week in Postgres.
-- ============================================================================

   SELECT 
         DATE_TRUNC('year', TIMESTAMP '2025-08-22 22:19:58') AS trunc_year;
   SELECT 
         DATE_TRUNC('day', TIMESTAMP '2025-08-22 22:19:58') AS trunc_day;
   SELECT 
         DATE_TRUNC('hour', TIMESTAMP '2025-08-22 22:19:58') AS trunc_hour;
   SELECT 
         DATE_TRUNC('week', TIMESTAMP '2025-08-22 22:19:58') AS trunc_week;


-- ============================================================================
-- 3) EXTRACTING PARTS FROM TIMESTAMP
--    date_part(text, timestamp) and EXTRACT(field FROM source) are equivalent.
--    Prefer EXTRACT for ANSI-like syntax. Field names are typically singular.
-- ============================================================================

-- Using date_part (returns DOUBLE PRECISION)
SELECT DATE_PART('day',   CURRENT_TIMESTAMP)  AS day_of_month;
SELECT DATE_PART('month', CURRENT_TIMESTAMP)  AS month_of_year;
SELECT DATE_PART('year',  CURRENT_TIMESTAMP)  AS year_number;

-- Using EXTRACT
SELECT EXTRACT(DAY   FROM CURRENT_TIMESTAMP) AS day_of_month_v2;
SELECT EXTRACT(HOUR  FROM CURRENT_TIMESTAMP) AS hour_of_day;


-- ============================================================================
-- 4) HUMAN-READABLE FORMATTING (to_char)
--    See: https://www.postgresql.org/docs/current/functions-formatting.html
--    'Day'/'Month' (capitalized) give capitalized names; 'day'/'month' are padded.
-- ============================================================================

SELECT TO_CHAR(CURRENT_TIMESTAMP, 'Day')   AS day_name;
SELECT TO_CHAR(CURRENT_TIMESTAMP, 'Month') AS month_name;


-- ============================================================================
-- 5) CONSTRUCTING / PARSING DATES
-- ============================================================================

-- Construct a DATE directly
SELECT MAKE_DATE(1977, 10, 26) AS birthday;

-- Parse a string into DATE with to_date (be explicit with the format mask)
SELECT TO_DATE(CONCAT('2020','-','09','-','01'), 'YYYY-MM-DD') AS parsed_date;


-- ============================================================================
-- 6) DATE ARITHMETIC
--    date - date = INTEGER (days)
--    AGE(later, earlier) = INTERVAL (years-months-days)
-- ============================================================================

-- Days between two dates (negative means the left is earlier than the right)
SELECT DATE '1977-10-26' - DATE '2025-08-26' AS days_diff_1;
SELECT DATE '2025-08-01' - DATE '2025-08-26' AS days_diff_2;
SELECT DATE '2025-08-26' - DATE '2025-08-01' AS days_diff_3;

-- AGE() returns an INTERVAL (years mons days) between two dates/timestamps
SELECT AGE(DATE '2020-05-31', DATE '2020-06-30') AS age_interval_1;
SELECT AGE(DATE '2026-09-24', DATE '1977-10-26') AS age_interval_2;

-- Extract parts from AGE() (use singular fields: year, month, day)
SELECT
    EXTRACT(YEAR  FROM AGE(DATE '2025-10-25', DATE '1977-10-26')) AS years_part,
    EXTRACT(MONTH FROM AGE(DATE '2025-10-25', DATE '1977-10-26')) AS months_part,
    EXTRACT(DAY   FROM AGE(DATE '2025-10-25', DATE '1977-10-26')) AS days_part;


SELECT DATE_PART('MONTH',AGE('2020-06-30','2020-01-01')) AS MONTHS;
SELECT DATE_PART('YEAR',AGE('2026-06-30','2020-01-01')) AS MONTHS;


-- Add an INTERVAL to a DATE
SELECT DATE '1977-10-26' + INTERVAL '48 years' AS plus_48_years;


-- ============================================================================
-- 7) TIME ARITHMETIC
--    You can add/subtract INTERVALs to/from TIME values.
--    NOTE: Multiplying a TIME by a number is NOT valid; multiply the INTERVAL.
-- ============================================================================

-- Add/subtract hours
SELECT TIME '05:00' + INTERVAL '3 hours' AS time_plus_3h;
SELECT TIME '05:00' - INTERVAL '3 hours' AS time_minus_3h;

-- Multiply an INTERVAL (result stays INTERVAL), then add to TIME if needed
SELECT INTERVAL '1 second' * 2000 AS interval_multiplied;           -- 2000 seconds
SELECT TIME '05:00' + (INTERVAL '1 hour' * 2) AS time_plus_2h;      -- 07:00


-- ============================================================================
-- 8) RETAIL SALES ANALYSIS
--    Table: retail_sales(sales_month DATE, kind_of_business TEXT, sales NUMERIC/DECIMAL)
--    Tips:
--      * Always add ORDER BY in analytics outputs for readability.
--      * Cast to NUMERIC/DECIMAL in pct calcs to avoid integer division.
-- ============================================================================

-- Peek sample rows
SELECT *
FROM retail_sales
ORDER BY sales_month, kind_of_business
LIMIT 100;

-- Monthly trend: total retail + food services
SELECT
    sales_month,
    sales
FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total'
ORDER BY sales_month;

-- Yearly total: retail + food services (GROUP BY year)
SELECT
    DATE_PART('year', sales_month) AS sales_year,
    SUM(sales)                     AS sales
FROM retail_sales
WHERE kind_of_business = 'Retail and food services sales, total'
GROUP BY 1
ORDER BY 1;

-- Yearly comparison across selected components
SELECT
    DATE_PART('year', sales_month) AS sales_year,
    kind_of_business,
    SUM(sales) AS sales
FROM retail_sales
WHERE kind_of_business IN (
    'Book stores',
    'Sporting goods stores',
    'Hobby, toy, and game stores'
)
GROUP BY 1, 2
ORDER BY 1, 2;

-- Monthly trend for Men’s vs Women’s clothing
SELECT
    sales_month,
    kind_of_business,
    sales
FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores', 'Women''s clothing stores')
ORDER BY sales_month, kind_of_business;

-- Simple banding with CASE
SELECT
    sales_month,
    kind_of_business,
    sales,
    CASE
        WHEN sales >= 1000 THEN 'high_sales'
        WHEN sales <= 500  THEN 'low_sales'
        ELSE 'mid_sales'
    END AS sales_band
FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores', 'Women''s clothing stores')
ORDER BY sales_month, kind_of_business;

-- Year aggregates for Men’s & Women’s clothing
SELECT
    DATE_PART('year', sales_month) AS sales_year,
    kind_of_business,
    SUM(sales) AS sales
FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores', 'Women''s clothing stores')
GROUP BY 1, 2
ORDER BY 1, 2;

-- Yearly pivot-style grouping (separate totals per year)
SELECT
    DATE_PART('year', sales_month) AS sales_year,
    SUM(CASE WHEN kind_of_business = 'Women''s clothing stores' THEN sales END) AS women_sales,
    SUM(CASE WHEN kind_of_business = 'Men''s clothing stores'   THEN sales END) AS men_sales
FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores', 'Women''s clothing stores')
GROUP BY 1
ORDER BY 1;

-- Difference (Women - Men) by year up to 2019-12-01
SELECT
    DATE_PART('year', sales_month) AS sales_year,
    SUM(CASE WHEN kind_of_business = 'Women''s clothing stores' THEN sales END)
  - SUM(CASE WHEN kind_of_business = 'Men''s clothing stores'   THEN sales END)
    AS womens_minus_mens
FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores', 'Women''s clothing stores')
  AND sales_month <= DATE '2019-12-01'
GROUP BY 1
ORDER BY 1;

-- Percent difference between Women’s and Men’s by year (<= 2019-12-01)
-- Use NUMERIC casts (or multiply by 100.0) to avoid integer division.
WITH yearly AS (
    SELECT
        DATE_PART('year', sales_month) AS sales_year,
        SUM(CASE WHEN kind_of_business = 'Women''s clothing stores' THEN sales END) AS womens_sales,
        SUM(CASE WHEN kind_of_business = 'Men''s clothing stores'   THEN sales END) AS mens_sales
    FROM retail_sales
    WHERE kind_of_business IN ('Men''s clothing stores', 'Women''s clothing stores')
      AND sales_month <= DATE '2019-12-01'
    GROUP BY 1
)
SELECT
    sales_year,
    ((womens_sales::NUMERIC / mens_sales::NUMERIC) - 1) * 100.0 AS womens_pct_of_mens
FROM yearly
ORDER BY sales_year;

-- --------------------------------------------------------------------------
-- Percent-of-Total (same-month denominator) — JOIN approach
-- --------------------------------------------------------------------------
WITH base AS (
    SELECT a.sales_month, a.kind_of_business, a.sales
    FROM retail_sales a
    WHERE a.kind_of_business IN ('Men''s clothing stores', 'Women''s clothing stores')
),
totals AS (
    SELECT sales_month, SUM(sales) AS total_sales
    FROM base
    GROUP BY sales_month
)
SELECT
    b.sales_month,
    b.kind_of_business,
    b.sales,
    (b.sales::NUMERIC * 100.0) / t.total_sales::NUMERIC AS pct_total_sales
FROM base b
JOIN totals t
  ON b.sales_month = t.sales_month
ORDER BY b.sales_month, b.kind_of_business;

-- --------------------------------------------------------------------------
-- Percent-of-Total — WINDOW FUNCTION approach (cleaner, no self-join)
-- --------------------------------------------------------------------------
SELECT
    sales_month,
    kind_of_business,
    sales,
    SUM(sales) OVER (PARTITION BY sales_month)                            AS total_sales,
    (sales::NUMERIC * 100.0) / SUM(sales) OVER (PARTITION BY sales_month) AS pct_total
FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores', 'Women''s clothing stores')
ORDER BY sales_month, kind_of_business;

-- --------------------------------------------------------------------------
-- Yearly share of each category (Men vs Women) within the same year
-- --------------------------------------------------------------------------
SELECT
    sales_month,
    kind_of_business,
    sales,
    SUM(sales) OVER (PARTITION BY DATE_PART('year', sales_month), kind_of_business) AS yearly_sales,
    (sales::NUMERIC * 100.0) / SUM(sales) OVER (PARTITION BY DATE_PART('year', sales_month), kind_of_business) AS pct_yearly
FROM retail_sales
WHERE kind_of_business IN ('Men''s clothing stores', 'Women''s clothing stores')
ORDER BY DATE_PART('year', sales_month), kind_of_business, sales_month;



-- Index to see Percent change over time 

SELECT 
    sales_year, 
    sales , 
    first_value(sales) over (ORDER BY sales_year) AS index_sales
FROM
    (   SELECT 
            date_part('year',sales_month) AS sales_year , 
            SUM(sales)                    AS sales
        FROM 
            retail_sales
        WHERE 
            kind_of_business = 'Women''s clothing stores'
        GROUP BY 
            1 ) a;


--- find the percent change from this base year for each row:

WITH 
    cet AS 
    (   SELECT 
            date_part('year',sales_month) AS sales_year , 
            SUM(sales)                    AS sales
        FROM 
            retail_sales
        WHERE 
            kind_of_business = 'Women''s clothing stores'
        GROUP BY 
            1
    )
SELECT 
    sales_year, 
    sales , 
    first_value(sales) over (ORDER BY sales_year) AS index_sales
FROM 
    cet; 


--

SELECT 
     sales_year, 
     sales,
     (sales / first_value(sales) over (order by sales_year) - 1) * 100
as pct_from_index
FROM
(
     SELECT 
           date_part('year',sales_month) as sales_year,
           sum(sales) as sales
   FROM retail_sales
   WHERE kind_of_business = 'Women''s clothing stores'
   GROUP BY 1) a;

-- Rolling Time Windows








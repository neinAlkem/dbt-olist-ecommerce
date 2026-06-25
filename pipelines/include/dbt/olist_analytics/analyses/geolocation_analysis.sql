/* -------------------------- check total duplicate ------------------------- */
SELECT 
    geolocation_zip_code_prefix, count(1) AS total_duplicate
FROM
    {{ ref("staging_location") }}
GROUP BY
    geolocation_zip_code_prefix
HAVING
    count(geolocation_zip_code_prefix) > 1    
ORDER BY 
    geolocation_zip_code_prefix DESC;

/* ----------------------------- Identify sample ---------------------------- */
SELECT 
    *
FROM
    {{ ref("staging_location") }}
WHERE
    geolocation_city = 'diadema';

/* ------------------------------- Sample all ------------------------------- */
WITH row_num AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix ORDER BY geolocation_zip_code_prefix) AS row_num
    FROM
        {{ ref("staging_location") }}
),

duplicate_zip AS (
    SELECT 
    geolocation_zip_code_prefix, count(1) AS total_duplicate
FROM
    {{ ref("staging_location") }}
GROUP BY
    geolocation_zip_code_prefix
HAVING
    count(geolocation_zip_code_prefix) > 1    
)

SELECT
    *
FROM
    row_num
WHERE
    geolocation_zip_code_prefix IN (
        SELECT geolocation_zip_code_prefix FROM duplicate_zip
    )
ORDER BY 
    geolocation_zip_code_prefix DESC, 
    row_num ASC;

/* ------------------------------------ - ----------------------------------- */

-- ANALYTIC DECISION RESULT

-- We will remove duplicated value with window combination of geolocation_zip_code_prefix and geolocation_city
-- If there are duplicate in the combination, we'll pick the winner or ( row_num = 1 )
-- Hence, this transformation executed because geolocation_lat and geolocation_ing does not provide any relationship to other columns/tables

/* ------------------------------------ - ----------------------------------- */




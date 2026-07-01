WITH 
    generated_date AS (
        {{ dbt_date.get_date_dimension('1999-01-01', '2099-12-31') }}
    ),
    
    dim_date AS (
        SELECT
            generated_date.date_day AS full_date,
            generated_date.day_of_week AS day_of_week,
            CASE
                WHEN generated_date.day_of_week = 1 THEN 'Sunday'
                WHEN generated_date.day_of_week = 2 THEN 'Monday'
                WHEN generated_date.day_of_week = 3 THEN 'Tuesday'
                WHEN generated_date.day_of_week = 4 THEN 'Wednesday'
                WHEN generated_date.day_of_week = 5 THEN 'Thursday'
                WHEN generated_date.day_of_week = 6 THEN 'Friday'
                WHEN generated_date.day_of_week = 7 THEN 'Saturday'
            END AS day_name,
            generated_date.day_of_month AS day_of_month,
            generated_date.week_of_year AS week_of_year,
            generated_date.month_of_year AS month_of_year,
            generated_date.month_name_short AS month_name,
            generated_date.quarter_of_year AS quarter_of_year,
            YEAR(generated_date.date_day) AS year,
            CASE   
                WHEN generated_date.day_of_week = 7 THEN 'Weekend'
                WHEN generated_date.day_of_week = 1 THEN 'Weekend'
                ELSE 'Non-Weekend'
            END AS is_weekend
        FROM
            generated_date
    )

SELECT 
    md5(cast(coalesce(cast(full_date AS STRING), '') as STRING)) AS date_id,
    *,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    dim_date
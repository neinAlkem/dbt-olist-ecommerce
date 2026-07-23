SELECT
    TRIM(city_name) AS city_name,
    TRIM(CAST(latitude AS STRING)) AS latitude,
    TRIM(CAST(longitude AS STRING)) AS longitude,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'cities_geo') }}
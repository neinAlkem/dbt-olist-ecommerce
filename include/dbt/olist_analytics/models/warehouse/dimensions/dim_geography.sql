WITH prefix_unique AS (

    SELECT
        SUBSTRING(zipcodes, 1, LEN(zipcodes) - 3) AS geolocation_zipcode_prefix,
        TRIM(city_name) AS geolocation_city,
        TRIM(state_name) AS geolocation_state
    FROM {{ ref('staging_geo_zipcodes') }}

),

unique_combination AS (
    SELECT DISTINCT
        geolocation_zipcode_prefix,
        geolocation_city,
        geolocation_state
    FROM prefix_unique
    WHERE geolocation_zipcode_prefix IS NOT NULL

)

SELECT
    TRIM(MD5(CAST(COALESCE(CONCAT(a.geolocation_zipcode_prefix,a.geolocation_city,a.geolocation_state),'') AS STRING))) AS geolocation_key,
    a.geolocation_zipcode_prefix AS geolocation_zip_code_prefix,
    a.geolocation_city,
    a.geolocation_state,
    TRIM(COALESCE(b.latitude, '0')) AS geolocation_lat,
    TRIM(COALESCE(b.longitude,'0')) AS geolocation_lng,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM unique_combination a
LEFT JOIN {{ ref('staging_geo_cities') }} b
    ON a.geolocation_city = b.city_name
SELECT 
    TRIM(geolocation_zip_code_prefix) AS geolocation_zip_code_prefix,
    TRIM(geolocation_lat) AS geolocation_lat,
    TRIM(geolocation_lng) AS geolocation_lng,
    TRIM(geolocation_city) AS geolocation_city,
    TRIM(geolocation_state) AS geolocation_state,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'olist_geolocation_dataset') }}
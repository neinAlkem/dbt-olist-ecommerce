SELECT
    TRIM(postal_code) AS zipcodes,
    TRIM(city_name) AS city_name,
    TRIM(state_name) AS state_name,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'zipcodes_geo') }}

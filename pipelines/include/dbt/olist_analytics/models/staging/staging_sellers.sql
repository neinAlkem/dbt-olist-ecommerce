SELECT 
    TRIM(seller_id) AS seller_id,
    TRIM(CAST(seller_zip_code_prefix AS CHAR(5))) AS seller_zip_code_prefix,
    TRIM(seller_city) AS seller_city,
    TRIM(seller_state) AS seller_state,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'olist_sellers_dataset') }}
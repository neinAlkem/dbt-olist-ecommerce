SELECT 
    TRIM(seller_id) AS seller_key,
    TRIM(CAST(seller_zip_code_prefix AS CHAR(5))) AS seller_zip_code_prefix,
    TRIM(seller_city) AS seller_city,
    TRIM(seller_state) AS seller_state,
    MD5(CONCAT(
            COALESCE(CAST(seller_id AS STRING),''),
            COALESCE(CAST(seller_zip_code_prefix AS STRING),''),
            COALESCE(seller_city,''),
            COALESCE(seller_state,'')
        )) AS scd_id,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'olist_sellers_dataset') }}
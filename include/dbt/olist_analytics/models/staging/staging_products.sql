SELECT
    TRIM(product_id) AS product_id,
    TRIM(product_category_name) AS product_category_name,
    TRIM(CAST(product_name_lenght AS INT)) AS product_name_lenght,
    TRIM(CAST(product_description_lenght AS INT)) AS product_description_lenght,
    TRIM(CAST(product_photos_qty AS INT)) AS product_photos_qty,
    TRIM(CAST(product_weight_g AS DOUBLE)) AS product_weight_g,
    TRIM(CAST(product_length_cm AS FLOAT)) AS product_length_cm,
    TRIM(CAST(product_height_cm AS FLOAT)) AS product_height_cm,
    TRIM(CAST(product_width_cm AS FLOAT)) AS product_width_cm,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'olist_products_dataset') }}

SELECT
    TRIM(product_category_name) AS product_category_name,
    TRIM(product_category_name_english) AS product_category_name_english,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'product_category_name_translation') }}
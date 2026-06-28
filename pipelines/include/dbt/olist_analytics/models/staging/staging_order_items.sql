SELECT 
    TRIM(order_id) AS order_id,
    TRIM(CAST(order_item_id AS INT)) AS order_item_id,
    TRIM(product_id) AS product_id,
    TRIM(seller_id) AS seller_id,
    TRIM(CAST(shipping_limit_date AS TIMESTAMP)) AS shipping_limit_date,
    TRIM(CAST(price AS DOUBLE)) AS price,
    TRIM(CAST(freight_value AS DOUBLE)) AS freight_value,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'olist_order_items_dataset') }}
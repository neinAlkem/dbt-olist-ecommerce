SELECT
    TRIM(order_id) AS order_id,
    TRIM(customer_id) AS customer_id,
    TRIM(order_status) AS order_status,
    TRIM(CAST(order_purchase_timestamp AS TIMESTAMP)) AS order_purchase_timestamp,
    TRIM(CAST(order_approved_at AS TIMESTAMP)) AS order_approved_at,
    TRIM(CAST(order_delivered_carrier_date AS TIMESTAMP)) AS order_delivered_carrier_date,
    TRIM(CAST(order_delivered_customer_date AS TIMESTAMP)) AS order_delivered_customer_date,
    TRIM(CAST(order_estimated_delivery_date AS TIMESTAMP)) AS order_estimated_delivery_date,
    MD5(COALESCE(CONCAT(order_id,customer_id),'')) AS incremental_hash,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'olist_orders_dataset') }}

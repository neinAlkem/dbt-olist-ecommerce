SELECT
    TRIM(order_id) AS order_id,
    TRIM(CAST(payment_sequential AS INT)) AS payment_sequential,
    TRIM(payment_type) AS payment_type,
    TRIM(CAST(payment_installments AS INT)) AS payment_installments,
    TRIM(CAST(payment_value AS DOUBLE)) AS payment_value,
    CURRENT_TIMESTAMP() AS load_timestamp 
FROM
    {{ source('raw', 'olist_order_payments_dataset') }}
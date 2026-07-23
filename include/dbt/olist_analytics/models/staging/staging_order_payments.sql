SELECT
    TRIM(order_id) AS order_id,
    TRIM(CAST(payment_sequential AS INT)) AS payment_sequential,
    TRIM(payment_type) AS payment_type,
    TRIM(CAST(payment_installments AS INT)) AS payment_installments,
    TRIM(CAST(payment_value AS DOUBLE)) AS payment_value,
    MD5(COALESCE(CONCAT(order_id,payment_sequential),'')) AS incremental_hash,
    CURRENT_TIMESTAMP() AS load_timestamp 
FROM
    {{ source('raw', 'olist_order_payments_dataset') }}
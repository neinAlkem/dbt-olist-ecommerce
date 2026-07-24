SELECT
    TRIM(customer_id) AS customer_id,
    TRIM(customer_unique_id) AS customer_unique_id,
    TRIM(customer_zip_code_prefix) AS customer_zip_code_prefix,
    TRIM(customer_city) AS customer_city,
    TRIM(customer_state) AS customer_state,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'olist_customers_dataset') }}
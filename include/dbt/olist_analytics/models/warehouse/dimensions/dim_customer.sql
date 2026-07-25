SELECT
    DISTINCT(customer_id) AS customer_key,
    customer_unique_id, 
    customer_zip_code_prefix, 
    customer_city, 
    customer_state, 
    DATE_FORMAT(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS load_timestamp
FROM
    {{ ref('staging_customer') }}

{% if is_incremental() %}
    WHERE customer_id 
        NOT IN (SELECT customer_key FROM {{ this }})
{% endif %}
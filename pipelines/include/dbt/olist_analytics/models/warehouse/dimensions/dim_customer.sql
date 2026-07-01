SELECT
    DISTINCT(customer_id) AS customer_key,
    customer_unique_id, 
    customer_zip_code_prefix, 
    customer_city, 
    customer_state, 
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ ref('staging_customer') }}

{% if is_incremental() %}
        WHERE load_timestamp > (SELECT MAX(load_timestamp) FROM {{ this }})
{% endif %}
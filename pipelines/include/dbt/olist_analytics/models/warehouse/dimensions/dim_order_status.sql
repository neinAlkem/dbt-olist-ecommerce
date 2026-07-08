SELECT
    TRIM(MD5(CAST(COALESCE(CAST(order_status_name AS STRING), '') AS STRING))) AS order_status_key,
    TRIM(CAST(order_status_code AS CHAR(3))) AS order_status_code,
    TRIM(order_status_name) AS order_status_name,
    TRIM(status_category) AS status_category,
    TRIM(CAST(status_sequence AS CHAR(3))) AS status_sequence,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ ref('order_status') }}

{% if is_incremental() %}
WHERE
    load_timestamp > (SELECT MAX(load_timestamp) FROM {{ this }})
{% endif %}
SELECT 
    TRIM(CAST(a.product_id AS STRING)) AS product_key,
    COALESCE(TRIM(CAST(b.product_category_name_english AS STRING)), 'Unknown') AS product_category_name_english,
    COALESCE(TRIM(ROUND(CAST(a.product_weight_g AS FLOAT), 2)), 0.00) AS product_weight_g,
    COALESCE(TRIM(ROUND(CAST((CAST(a.product_length_cm AS FLOAT) * CAST(a.product_height_cm AS FLOAT) * CAST(a.product_width_cm AS FLOAT)) AS FLOAT), 2)), 0.00) AS product_volume_cm3,
    COALESCE(TRIM(ROUND(CAST(a.product_length_cm AS FLOAT), 2)), 0.00) AS product_length_cm,
    COALESCE(TRIM(ROUND(CAST(a.product_height_cm AS FLOAT), 2)), 0.00) AS product_height_cm,
    COALESCE(TRIM(ROUND(CAST(a.product_width_cm AS FLOAT), 2)), 0.00) AS product_width_cm,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ ref('staging_products') }} a
LEFT JOIN
    {{ ref('staging_category_name_translation') }} b
ON
    a.product_category_name = b.product_category_name

{% if is_incremental() %}
WHERE
    a.load_timestamp > (SELECT MAX(load_timestamp) FROM {{ this }})
{% endif %}

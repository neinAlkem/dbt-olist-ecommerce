WITH lowest_grain AS (

    SELECT
        COALESCE(a.full_date, NULL) AS purchase_date,
        COALESCE(b.customer_unique_id, 'Unknown') AS customer_id,
        COALESCE(c.seller_key, 'Unknown') AS seller_id,
        COALESCE(d.product_key, 'Unknown') AS product_id,
        COALESCE(f.order_id, 'Unknown') AS order_id,
        COALESCE(f.order_item_id, 0) AS quantity_counter,
        COALESCE(e.order_status_name, 'Unknown') AS order_status,
        COALESCE(ROUND(CAST(f.price AS FLOAT), 2), 0) AS price,
        COALESCE(ROUND(CAST(f.freight_value AS FLOAT), 2), 0) AS freight_value,
        COALESCE(ROUND(CAST(f.price AS FLOAT) + CAST(f.freight_value AS FLOAT), 2),0) AS total_price,
        f.incremental_hash AS incremental_hash
    FROM 
        {{ ref('staging_order_items') }} f
    LEFT JOIN
        {{ ref('staging_orders') }} z 
        ON f.order_id = z.order_id
    LEFT JOIN
        {{ ref('dim_date') }} a
        ON a.full_date = CAST(z.order_purchase_timestamp AS DATE)
    LEFT JOIN {{ ref("dim_customer") }} b
        ON z.customer_id = b.customer_key
    LEFT JOIN {{ ref("dim_seller") }} c
        ON f.seller_id = c.seller_key
    LEFT JOIN {{ ref("dim_product") }} d
        ON f.product_id = d.product_key
    LEFT JOIN {{ ref("dim_order_status") }} e
        ON z.order_status = e.order_status_name

    {% if is_incremental() %}
    WHERE f.load_timestamp >= ( SELECT MAX(load_timestamp)FROM {{ this }} )
    {% endif %}

)

SELECT
    *,
    DATE_FORMAT(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS load_timestamp
FROM lowest_grain;

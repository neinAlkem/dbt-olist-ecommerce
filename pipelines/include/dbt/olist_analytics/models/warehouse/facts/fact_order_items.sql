WITH lowest_grain AS (

    SELECT
        a.full_date AS purchase_date,
        b.customer_unique_id AS customer_id,
        c.seller_key AS seller_id,
        d.product_key AS product_id,
        f.order_id AS order_id,
        f.order_item_id AS quantity_counter,
        e.order_status_name AS order_status,
        ROUND(CAST(f.price AS FLOAT),2) AS price,
        ROUND(CAST(f.freight_value AS FLOAT),2) AS freight_value,
        ROUND(CAST(f.price AS FLOAT) + CAST(f.freight_value AS FLOAT),2) AS total_price,
        f.incremental_hash AS incremental_hash
    FROM {{ ref("dim_date") }} a
    JOIN {{ ref("staging_orders") }} z
        ON a.full_date = CAST(z.order_purchase_timestamp AS DATE)
    JOIN {{ ref("staging_order_items") }} f
        ON z.order_id = f.order_id
    JOIN {{ ref("dim_customer") }} b
        ON z.customer_id = b.customer_key
    JOIN {{ ref("dim_seller") }} c
        ON f.seller_id = c.seller_key
    JOIN {{ ref("dim_product") }} d
        ON f.product_id = d.product_key
    JOIN {{ ref("dim_order_status") }} e
        ON z.order_status = e.order_status_name

    {% if is_incremental() %}
    WHERE f.load_timestamp >= ( SELECT MAX(load_timestamp)FROM {{ this }} )
    {% endif %}

)

SELECT
    *,
    DATE_FORMAT(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS load_timestamp
FROM lowest_grain;
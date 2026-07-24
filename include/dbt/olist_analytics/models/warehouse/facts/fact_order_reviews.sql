with lowest_grain AS (
    SELECT
        COALESCE(CAST(a.review_id AS STRING), 'Unknown') AS review_id,
        COALESCE(CAST(a.order_id AS STRING), 'Unknown') AS order_id,
        COALESCE(CAST(b.customer_unique_id AS STRING), 'Unknown') AS customer_id,
          COALESCE(CAST(a.review_score AS INT), 1) AS review_score,
        CASE 
            WHEN a.review_comment_message IS NOT NULL THEN TRUE ELSE FALSE
        END AS has_comment,
        a.incremental_hash as incremental_hash
    FROM
        {{ ref("staging_order_reviews")}} a
    LEFT JOIN
        {{ ref("staging_orders")}} z
        ON a.order_id = z.order_id
    LEFT JOIN
        {{ ref("dim_customer")}} b
        ON z.customer_id = b.customer_key

    {% if is_incremental() %}
    WHERE a.load_timestamp >= ( SELECT MAX(load_timestamp)  FROM {{ this }} )
    {% endif %}
)

SELECT
    review_id,
    order_id,
    customer_id,
    review_score,
    has_comment,
    incremental_hash,
    DATE_FORMAT(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS load_timestamp
FROM
    lowest_grain;
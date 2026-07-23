WITH lowest_grain AS (
    SELECT
        COALESCE(a.order_id,'Unknown') AS order_id, 
        COALESCE(b.customer_unique_id, 'Unknown') AS customer_id,
        COALESCE(c.order_status_name, 'Unknown') AS order_status,
        COALESCE(d.full_date, NULL) AS purchase_date,
        COALESCE(e.full_date, NULL) AS approved_date,
        COALESCE(f.full_date, NULL) AS shipped_date,
        COALESCE(g.full_date, NULL) AS arrival_date,
        COALESCE(h.full_date, NULL) AS estimated_arrival_date,
        a.incremental_hash AS incremental_hash
    FROM
        {{ ref('staging_orders') }} a
    LEFT JOIN 
        {{ ref('dim_customer')}} b
        ON a.customer_id = b.customer_key
    LEFT JOIN
        {{ ref('dim_order_status') }} c
        ON a.order_status = c.order_status_name
    LEFT JOIN 
        {{ ref('dim_date') }} d
        ON d.full_date = CAST(a.order_purchase_timestamp AS DATE) 
    LEFT JOIN 
        {{ ref('dim_date') }} e
        ON e.full_date = CAST(a.order_approved_at AS DATE) 
    LEFT JOIN 
        {{ ref('dim_date') }} f
        ON f.full_date = CAST(a.order_delivered_carrier_date AS DATE) 
    LEFT JOIN 
        {{ ref('dim_date') }} g
        ON g.full_date = CAST(a.order_delivered_customer_date AS DATE) 
    LEFT JOIN 
        {{ ref('dim_date') }} h
        ON h.full_date = CAST(a.order_estimated_delivery_date AS DATE) 

    {% if is_incremental() %}
    WHERE a.load_timestamp >= ( SELECT MAX(load_timestamp)  FROM {{ this }} )
    {% endif %}
)

SELECT
    order_id,
    customer_id,
    order_status,
    purchase_date,
    approved_date,
    shipped_date,
    arrival_date,
    estimated_arrival_date,
    CASE
        WHEN approved_date IS NOT NULL AND purchase_date IS NOT NULL 
        THEN DATEDIFF(day, purchase_date, approved_date) 
        ELSE NULL
    END AS days_to_approve,
    CASE
        WHEN shipped_date IS NOT NULL AND approved_date IS NOT NULL 
        THEN DATEDIFF(day, approved_date, shipped_date) 
        ELSE NULL
    END AS days_to_shipped,
    CASE
        WHEN arrival_date IS NOT NULL AND shipped_date IS NOT NULL 
        THEN DATEDIFF(day, shipped_date, arrival_date) 
        ELSE NULL
    END AS days_to_arrived,
    CASE
        WHEN arrival_date IS NOT NULL AND purchase_date IS NOT NULL 
        THEN DATEDIFF(day, purchase_date, arrival_date) 
        ELSE NULL
    END AS total_fullfillment_days,
    CASE
        WHEN arrival_date IS NOT NULL AND estimated_arrival_date IS NOT NULL 
        THEN DATEDIFF(day, estimated_arrival_date, arrival_date) 
        ELSE NULL
    END AS days_prediction_arrived_diff,
    CASE
        WHEN arrival_date IS NOT NULL AND DATEDIFF(day, estimated_arrival_date, arrival_date) <= 0 
        THEN 'TRUE' 
        ELSE 'FALSE'
    END AS is_on_time_delivery, 
    incremental_hash,
    DATE_FORMAT(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS load_timestamp
FROM lowest_grain;

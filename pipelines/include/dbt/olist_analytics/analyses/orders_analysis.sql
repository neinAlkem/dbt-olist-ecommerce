/* -------------------------- Check accepted values ------------------------- */
SELECT 
    DISTINCT(order_status)
FROM
    {{ source('raw', 'olist_orders_dataset') }};

/* ------------------------------ Sanity checks ----------------------------- */
SELECT
    *
FROM
    {{ source('raw', 'olist_orders_dataset') }}
WHERE
    order_status = 'unavailable'

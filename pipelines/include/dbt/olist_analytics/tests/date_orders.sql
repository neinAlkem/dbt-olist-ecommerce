SELECT 
    *
FROM
    {{ ref('staging_orders') }}
WHERE
    order_approved_at < order_purchase_timestamp
    AND order_delivered_carrier_date < order_approved_at
    AND order_delivered_customer_date < order_delivered_carrier_date
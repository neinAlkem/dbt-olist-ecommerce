/* ---------------------------------- TEST ---------------------------------- */

-- Test to check if all order_approved_at, order_delivered_carrier_date, and order_delivered_customer_date values in staging_orders are greater than or equal to order_purchase_timestamp
-- Target table: staging_orders
-- Test description: This test ensures that all order_approved_at, order_delivered_carrier_date, and order_delivered_customer_date values in staging_orders are greater than or equal to order_purchase_timestamp. If any values do not meet this criteria, they will be flagged as failing the test.
-- Last Updated: 08/07/2026

/* ----------------------------------- END ---------------------------------- */

SELECT 
    *
FROM
    {{ ref('staging_orders') }}
WHERE
    order_approved_at < order_purchase_timestamp
    AND order_delivered_carrier_date < order_approved_at
    AND order_delivered_customer_date < order_delivered_carrier_date
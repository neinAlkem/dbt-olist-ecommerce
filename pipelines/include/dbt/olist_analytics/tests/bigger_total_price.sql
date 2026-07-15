/* ---------------------------------- TEST ---------------------------------- */

-- Test to check total_price column in fact_order_items have bigger total then the price column
-- Target table: fact_order_items
-- Test description: this test check whaetever there are a row having bigger price then the total price of the order
-- Last Updated: 15/07/2026

/* ----------------------------------- END ---------------------------------- */

SELECT
    *
FROM
    {{ ref('fact_order_items') }}
WHERE
    total_price < price
/* -------------------- Check accepted payment type value ------------------- */
SELECT
    DISTINCT(payment_type)
FROM
    {{ source('raw', 'olist_order_payments_dataset') }};

/* ------------------------------- Rows check ------------------------------- */
SELECT 
    * 
FROM 
        {{ source('raw', 'olist_order_payments_dataset') }}
WHERE 
    payment_type = 'not_defined'

/* ------------------------------------ - ----------------------------------- */

-- ANALYTIC DECISION RESULT

-- Remove rows where payment_type is not_defined
-- This decision happen because the payment_value is 0
-- Hence, indicating not valid transcaction in system

/* ------------------------------------ - ----------------------------------- */
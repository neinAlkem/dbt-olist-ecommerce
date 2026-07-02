/* -------------------------- Check for duplicates -------------------------- */
WITH row_num AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY payment_sequential DESC) AS row_number
    FROM
        {{ ref('staging_order_payments') }}
)
SELECT * FROM row_num WHERE row_number > 1
LIMIT 100;

/* --------------------- Installements avaibility check --------------------- */
SELECT
    payment_type,
    payment_installments
FROM
    {{ ref('staging_order_payments') }}
GROUP BY   
    payment_type,
    payment_installments;

SELECT DISTINCT
    MD5(CAST(COALESCE(CAST(payment_type AS STRING), '') AS STRING)) AS payment_type_key,
    payment_type AS payment_type_name,
    CASE
        WHEN payment_type = 'credit_card' THEN TRUE
        ELSE FALSE
    END AS is_eligible_installment
FROM {{ ref('staging_order_payments') }};


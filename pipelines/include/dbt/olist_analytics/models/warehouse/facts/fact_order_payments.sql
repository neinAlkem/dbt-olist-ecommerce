WITH lowest_grain AS (
    SELECT
        COALESCE(CAST(a.order_id AS STRING), 'Unknown') AS order_id,
        COALESCE(CAST(a.payment_sequential AS INT), 1) AS payment_counter,
        COALESCE(b.full_date, '9999-12-31') AS payment_date,
        COALESCE(c.payment_type_name, NULL) AS payment_type_name,
        COALESCE(ROUND(CAST(a.payment_value AS FLOAT), 2), 0.00) AS payment_value,
        CASE 
            WHEN
                a.payment_installments = 0 THEN 1 
                ELSE a.payment_installments
            END AS payment_installments,
        a.incremental_hash
    FROM
        {{ ref('staging_order_payments')}} a
    JOIN
        {{ ref('staging_orders')}} z
        ON a.order_id = z.order_id
    LEFT JOIN
        {{ ref('dim_date')}} b 
        ON b.full_date = CAST(z.order_purchase_timestamp AS DATE)
    LEFT JOIN
        {{ ref('dim_payment_type')}} c 
        ON c.payment_type_name = 
            CASE a.payment_type
                WHEN 'credit_card' THEN 'Credit Card'
                WHEN 'debit_card' THEN 'Debit Card'
                WHEN 'voucher' THEN 'Voucher'
                WHEN 'boleto' THEN 'Boleto'
                ELSE NULL
            END

    {% if is_incremental() %}
    WHERE a.load_timestamp >= ( SELECT MAX(load_timestamp)  FROM {{ this }} )
    {% endif %}
)

SELECT
    order_id,
    payment_date,
    payment_counter,
    payment_type_name,
    payment_value,
    payment_installments,
    ROUND((payment_value / payment_installments), 2) AS installment_value,
    incremental_hash,
    DATE_FORMAT(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS load_timestamp
FROM
    lowest_grain;
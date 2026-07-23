SELECT
    MD5(CAST(COALESCE(CAST(payment_type_name AS STRING), '') AS STRING)) AS payment_type_key,
    trim(CAST(payment_type_code AS CHAR(3))) AS payment_type_code,
    TRIM(payment_type_name) AS payment_type_name,
    TRIM(is_eligable_installment) AS is_eligable_installment,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ ref('payment_type') }}
SELECT
    MD5(CAST(COALESCE(CAST(payment_type_name AS STRING), '') AS STRING)) AS payment_type_key,
    trim(CAST(payment_type_code AS CHAR(3))) AS payment_type_code,
    TRIM(payment_type_name) AS payment_type_name,
    TRIM(is_eligable_installment) AS is_eligable_installment,
    DATE_FORMAT(CURRENT_TIMESTAMP(), 'yyyy-MM-dd HH:mm:ss') AS load_timestamp
FROM
    {{ ref('payment_type') }}

{% if is_incremental() %}
WHERE payment_type_key 
    NOT IN (SELECT payment_type_key FROM {{ this }})
{% endif %}

SELECT
    customer_unique_id,
    count(*) as total_row
FROM
    {{ ref('staging_customer') }}
GROUP BY
    customer_unique_id
HAVING
    count(*) > 1;

SELECT 
    *
FROM {{ ref('staging_customer') }} sc
WHERE sc.customer_unique_id IN (
    SELECT customer_unique_id
    FROM {{ ref('staging_customer') }}
    GROUP BY customer_unique_id
    HAVING COUNT(*) > 1
)
ORDER BY
    sc.customer_unique_id,
    sc.customer_id;

SELECT
    *
FROM
    {{ ref('dim_customer') }}
WHERE
    customer_key = '508cae50c5c1e72079d266a513bca9ae';

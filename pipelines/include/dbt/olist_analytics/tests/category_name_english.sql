/* ---------------------------------- TEST ---------------------------------- */

-- Test to check if all product_category_name_english values in dim_product are present in staging_category_name_translation Or if they contain 'Unknown' in their name
-- Target table: dim_product
-- Test description: This test ensures that all product_category_name_english values in dim_product are either present in staging_category_name_translation or contain 'Unknown' in their name. If any values do not meet this criteria, they will be flagged as failing the test.
-- Last Updated: 08/07/2026

/* ----------------------------------- END ---------------------------------- */

SELECT 
    product_category_name_english
FROM
    {{ ref('dim_product') }}
WHERE
    product_category_name_english NOT IN (
        SELECT DISTINCT product_category_name_english
        FROM {{ ref('staging_category_name_translation') }}
    )
    OR    
        product_category_name_english LIKE '%Unknown%';
    ;



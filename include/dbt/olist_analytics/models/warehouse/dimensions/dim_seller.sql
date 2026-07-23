WITH source_data AS (
    SELECT *
    FROM {{ ref('staging_sellers') }}
)

{% if is_incremental() %}

,destination_data AS (
    SELECT *
    FROM {{ this }}
    WHERE is_active = TRUE
)

,new_or_changed AS (
    SELECT
        s.*
    FROM source_data s
    LEFT JOIN destination_data d
        ON s.seller_key = d.seller_key
    WHERE
        d.seller_key IS NULL
        OR
        s.scd_id
        <>
        d.scd_id
)

,expired AS (
    SELECT
        d.seller_key,
        d.seller_zip_code_prefix,
        d.seller_city,
        d.seller_state,
        d.scd_id,
        d.load_timestamp,
        CURRENT_TIMESTAMP() AS expiry_timestamp,
        FALSE AS is_active
    FROM destination_data d
    JOIN new_or_changed n
        ON d.seller_key = n.seller_key
)

,new_data AS (
    SELECT
        seller_key AS seller_key,
        seller_zip_code_prefix,
        seller_city,
        seller_state,
        scd_id,
        CURRENT_TIMESTAMP() AS load_timestamp,
        TIMESTAMP('9999-12-31 23:59:59') AS expiry_timestamp,
        TRUE AS is_active
    FROM new_or_changed
)

{% else %}

,new_data AS (
    SELECT
        seller_key AS seller_key,
        seller_zip_code_prefix,
        seller_city,
        seller_state,
        scd_id,
        CURRENT_TIMESTAMP() AS load_timestamp,
        TIMESTAMP('9999-12-31 23:59:59') AS expiry_timestamp,
        TRUE AS is_active
    FROM source_data
)

{% endif %}

SELECT *
FROM new_data

{% if is_incremental() %}

UNION ALL
SELECT *
FROM expired

{% endif %}
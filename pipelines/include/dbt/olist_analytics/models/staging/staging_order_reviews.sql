SELECT 
    TRIM(review_id) AS review_id,
    TRIM(order_id) AS order_id,
    TRIM(CAST(review_score AS INT)) AS review_score,
    TRIM(review_comment_title) AS review_comment_title,
    TRIM(review_comment_message) AS review_comment_message,
    CURRENT_TIMESTAMP() AS load_timestamp
FROM
    {{ source('raw', 'olist_order_reviews_dataset') }}

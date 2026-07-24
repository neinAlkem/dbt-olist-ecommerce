{% test generic_non_zero_negative(model, column_name) %}

SELECT
    {{ column_name }}
FROM {{ model }}
WHERE LENGTH(TRIM({{ column_name }})) <= 0

{% endtest %}
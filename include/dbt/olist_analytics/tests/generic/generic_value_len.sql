{% test generic_value_len(model, column_name, length) %}

SELECT
    {{ column_name }}
FROM {{ model }}
WHERE LENGTH(TRIM({{ column_name }})) > {{ length }}

{% endtest %}
{% test generic_not_tommorow(model, column_name) %}

SELECT
    {{ column_name }}
FROM
    {{ model }}
WHERE
    CAST({{ column_name }} AS DATE) > CAST(CURRENT_TIMESTAMP() AS DATE) 

{% endtest %}

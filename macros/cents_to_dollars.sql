{% macro cents_to_dollars(cents_column) %}
    ({{ cents_column }}::numeric / 100.0)
{% endmacro %}

<!-- models/intermediate/sales_database/int_sales_database__order.md -->
{% docs int_sales_database__order %}

## Order-level enriched model

One row per order. Enriches each order from `stg_sales_database__order` with:

- the customer location (`user_city`, `user_state`) from `stg_sales_database__user`;
- the aggregated `average_feedback_score` from `stg_sales_database__feedback`;
- the line aggregates from `stg_sales_database__order_item`: `total_order_amount`
  (sum of `price * quantity`), `total_items` (sum of quantities) and
  `total_distinct_items` (count of distinct products).

All joins are LEFT joins on the order, so an order with no feedback or no line
item is preserved with NULL aggregates. This model is the single source feeding
both `int_sales_database__user` and `mrt_order_daily_report`.

{% enddocs %}

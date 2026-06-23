<!-- models/mart/mrt_order_daily_report.md -->
{% docs mrt_order_daily_report %}

## Daily order report (mart)

Materialized as a **table**. Aggregates `int_sales_database__order` by day,
account manager and customer state, joining the account-manager mapping from
`stg_google_sheets__account_manager_region_mapping` on
**`user_state = state`** (the customer's geographic state, which is the join key
to the Google Sheet — not the order's lifecycle status).

Grain: one row per (`order_date`, `account_manager`, `user_state`). Metrics:

- `nb_orders`: number of distinct orders;
- `avg_items_per_order`: average number of items per order;
- `avg_feedback_score`: average feedback score;
- `avg_order_amount`: average order amount.

This table is exposed to the dashboards.

{% enddocs %}

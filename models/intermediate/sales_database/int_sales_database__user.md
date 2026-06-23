<!-- models/intermediate/sales_database/int_sales_database__user.md -->
{% docs int_sales_database__user %}

## User-level aggregate model

One row per user. Built **on top of** `int_sales_database__order` (DRY: it reuses
the order-level aggregates rather than re-reading the staging tables). For each
user it computes:

- `total_order`: number of distinct orders placed by the user;
- `total_amount_order`: total amount spent across all the user's orders.

The user list comes from `stg_sales_database__user` via a LEFT join, so users
with no order are kept with NULL aggregates.

{% enddocs %}

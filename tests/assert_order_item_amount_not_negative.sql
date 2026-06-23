-- Singular test (TD9 Ex2 Part 2.1)
-- Ensures no order line on stg_sales_database__order_item has a negative
-- total amount. The test PASSES when it returns 0 rows.
--
-- "Total amount" of a line = price * quantity. We also guard the individual
-- non-negative components (price, quantity, shipping_cost).

select
    order_item_pk,
    order_id,
    price,
    quantity,
    shipping_cost,
    (price * quantity) as line_amount
from {{ ref('stg_sales_database__order_item') }}
where (price * quantity) < 0
   or price         < 0
   or quantity      < 0
   or shipping_cost < 0

-- Singular test (TD9 Ex2 Part 2.2 — additional relevant test)
-- Ensures order dates are chronologically consistent: the approval and the
-- delivery of an order cannot happen before the order was created.
-- The test PASSES when it returns 0 rows.
--
-- NULL dates are ignored: a comparison against NULL yields NULL (not TRUE),
-- so orders that are not yet approved/delivered are never flagged.

select
    order_id,
    order_date,
    order_approved_date,
    delivered_date
from {{ ref('stg_sales_database__order') }}
where order_approved_date < order_date
   or delivered_date      < order_date

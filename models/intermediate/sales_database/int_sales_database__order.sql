-- models/intermediate/sales_database/int_sales_database__order.sql
with orders as (
    select * from {{ ref('stg_sales_database__order') }}
),

users as (
    select * from {{ ref('stg_sales_database__user') }}
),

order_items as (
    select
        order_id,
        sum(price * quantity)       as total_order_amount,
        sum(quantity)               as total_items,
        count(distinct product_id)  as total_distinct_items
    from {{ ref('stg_sales_database__order_item') }}
    group by order_id
),

feedback as (
    select
        order_id,
        avg(feedback_score)         as average_feedback_score
    from {{ ref('stg_sales_database__feedback') }}
    group by order_id
),

final as (
    select
        o.order_id,
        o.user_name,
        o.order_status,
        o.order_date          as order_created_at,
        o.order_approved_date as order_approved_at,
        u.user_city,
        u.user_state,
        f.average_feedback_score,
        oi.total_order_amount,
        oi.total_items,
        oi.total_distinct_items
    from orders o
    left join users       u  on o.user_name = u.user_name
    left join order_items oi on o.order_id  = oi.order_id
    left join feedback    f  on o.order_id  = f.order_id
)

select * from final
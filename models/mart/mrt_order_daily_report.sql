-- models/mart/mrt_order_daily_report.sql
{{ config(materialized='table') }}

with orders as (
    select * from {{ ref('int_sales_database__order') }}
),

mapping as (
    select * from {{ ref('stg_google_sheets__account_manager_region_mapping') }}
),

joined as (
    select
        cast(o.order_created_at as date) as order_date,
        m.account_manager,
        o.user_state,
        o.order_id,
        o.total_items,
        o.average_feedback_score,
        o.total_order_amount
    from orders o
    left join mapping m on o.user_state = m.state
),

final as (
    select
        order_date,
        account_manager,
        user_state,
        count(distinct order_id)        as nb_orders,
        avg(total_items)                as avg_items_per_order,
        avg(average_feedback_score)     as avg_feedback_score,
        avg(total_order_amount)         as avg_order_amount
    from joined
    group by order_date, account_manager, user_state
)

select * from final
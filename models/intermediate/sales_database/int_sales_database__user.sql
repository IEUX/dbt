-- models/intermediate/sales_database/int_sales_database__user.sql
with order_enriched as (
    select * from {{ ref('int_sales_database__order') }}
),

users as (
    select * from {{ ref('stg_sales_database__user') }}
),

user_agg as (
    select
        user_name,
        count(distinct order_id) as total_order,
        sum(total_order_amount)  as total_amount_order
    from order_enriched
    group by user_name
),

final as (
    select
        u.user_name,
        u.user_city,
        ua.total_amount_order,
        ua.total_order
    from users u
    left join user_agg ua on u.user_name = ua.user_name
)

select * from final
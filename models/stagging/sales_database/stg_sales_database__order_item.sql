with source as (
    select * from {{ source('sales_database', 'order_item') }}
),

renamed as (
    select
        concat(order_id, '-', product_id, '-', seller_id) as order_item_pk,
        order_id,
        product_id,
        seller_id,
        quantity,
        price,
        shipping_cost,
        pickup_limit_date
    from source
)

select distinct * from renamed
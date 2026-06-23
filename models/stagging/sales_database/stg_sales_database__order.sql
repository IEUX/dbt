with source as (
    select * from {{ source('sales_database', 'order') }}
),

renamed as (
    select
        order_id,                       -- clé primaire native
        user_name,                      -- FK vers user
        order_status,
        order_date,
        order_approved_date,
        pickup_date,
        delivered_date,
        estimated_time_delivery
    from source
)

select distinct * from renamed
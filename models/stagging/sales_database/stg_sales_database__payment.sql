-- stg_sales_database__payment.sql
with source as (
    select * from {{ source('sales_database', 'payment') }}
),

renamed as (
    select
        concat(order_id, '-', cast(payment_sequential as string)) as payment_pk,
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value
    from source
)

select distinct * from renamed
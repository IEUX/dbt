-- stg_sales_database__seller.sql
with source as (
    select * from {{ source('sales_database', 'seller') }}
),

renamed as (
    select
        seller_id,                          -- clé primaire native
        cast(seller_zip_code as string) as seller_zip_code,
        seller_city,
        seller_state
    from source
)

select distinct * from renamed
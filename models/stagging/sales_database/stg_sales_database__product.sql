-- stg_sales_database__product.sql
with source as (
    select * from {{ source('sales_database', 'product') }}
),

renamed as (
    select
        product_id,                     -- clé primaire native
        product_category,
        cast(product_name_lenght        as int64) as product_name_length,
        cast(product_description_lenght as int64) as product_description_length,
        cast(product_photos_qty         as int64) as product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm
    from source
)

select distinct * from renamed
with source as (
    select * from {{ source('sales_database', 'user') }}
),

renamed as (
    select
        user_name,                              -- clé primaire native
        cast(customer_zip_code as string) as user_zip_code,
        customer_city                     as user_city,
        customer_state                    as user_state
    from source
)

select distinct * from renamed
-- models/staging/google_sheets/stg_google_sheets__account_manager_region_mapping.sql
with source as (
    select * from {{ source('google_sheets', 'google_sheets') }}
),

renamed as (
    select
        state,              -- chaque state est rattaché à un account manager (PK)
        account_manager
    from source
)

select distinct * from renamed

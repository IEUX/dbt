-- models/staging/spotify/stg_spotify__listening_data.sql
with source as (
    select * from {{ source('spotify', 'listening_data') }}
),

cleaned as (
    select
        song_id,
        cast(listen_date as date)          as listen_date,
        coalesce(minutes_listened, 0)      as minutes_listened
    from source
)

select distinct * from cleaned
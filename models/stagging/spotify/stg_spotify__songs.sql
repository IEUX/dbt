-- models/staging/spotify/stg_spotify__songs.sql
with source as (
    select * from {{ source('spotify', 'songs') }}
),

cleaned as (
    select
        song_id,
        upper(artist)                  as artist,
        upper(title)                   as title,
        coalesce(genre, 'Unknown')     as genre
    from source
)

select distinct * from cleaned
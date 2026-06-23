-- models/intermediate/spotify/int_spotify__song_listening.sql
with songs as (
    select * from {{ ref('stg_spotify__songs') }}
),

listening as (
    select * from {{ ref('stg_spotify__listening_data') }}
),

joined as (
    select
        l.listen_date,
        l.minutes_listened,
        s.song_id,
        s.artist,
        s.title,
        s.genre
    from listening l
    inner join songs s on l.song_id = s.song_id
    where l.listen_date >= date_sub(current_date(), interval 2 year)
)

select * from joined
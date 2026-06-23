-- models/mart/mrt_spotify__top_artists.sql
{{ config(materialized='table') }}

with song_listening as (
    select * from {{ ref('int_spotify__song_listening') }}
),

ranked as (
    select
        artist,
        sum(minutes_listened) as minutes_listened
    from song_listening
    group by artist
)

select *
from ranked
order by minutes_listened desc
limit 20
<!-- models/intermediate/spotify/int_spotify__song_listening.md -->
{% docs int_spotify__song_listening %}

## Song listening model

Joins `stg_spotify__listening_data` with `stg_spotify__songs` on `song_id`,
producing one row per listening record enriched with the song's artist, title
and genre. The join is an INNER join, so listening records whose `song_id` has
no matching song are dropped. The result is restricted to the **last 2 years**
of listening history.

This model feeds `mrt_spotify__top_artists`.

{% enddocs %}

<!-- models/mart/mrt_spotify__top_artists.md -->
{% docs mrt_spotify__top_artists %}

## Top artists (mart)

Materialized as a **table**. From `int_spotify__song_listening`, sums
`minutes_listened` per artist and returns the **top 20 artists** ordered by total
minutes listened (descending).

Grain: one row per artist (top 20 only). This table is exposed to the dashboards.

{% enddocs %}

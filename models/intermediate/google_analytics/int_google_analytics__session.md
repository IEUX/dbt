<!-- models/intermediate/google_analytics/int_google_analytics__session.md -->
{% docs int_google_analytics__session %}

## Session-level model

Aggregates GA4 events from `stg_google_analytics__event` into one row per
session. A session is keyed by `unique_session_id`, the concatenation of
`user_pseudo_id` and `ga_session_id`. Events with a NULL `ga_session_id` are
excluded.

For each session it derives the time bounds (`session_start_time`,
`session_end_time`) and `session_duration_seconds`, the acquisition context
(browser, traffic medium / source / campaign), and activity counts
(`event_count`, `pages_viewed` = number of `page_view` events).

{% enddocs %}

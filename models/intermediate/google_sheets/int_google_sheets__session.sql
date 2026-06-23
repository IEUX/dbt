-- models/intermediate/google_analytics/int_google_sheets__session.sql
with events as (
    select * from {{ ref('stg_google_sheets__event') }}
),

sessions as (
    select
        concat(user_pseudo_id, '-', cast(ga_session_id as string)) as unique_session_id,
        user_pseudo_id,
        min(event_timestamp)                                       as session_start_time,
        max(event_timestamp)                                       as session_end_time,
        timestamp_diff(max(event_timestamp), min(event_timestamp), second) as session_duration_seconds,
        any_value(browser)                                         as browser_used,
        any_value(traffic_medium)                                  as traffic_medium,
        any_value(traffic_source)                                  as traffic_source,
        any_value(traffic_campaign_name)                           as traffic_name,
        count(*)                                                   as event_count,
        countif(event_name = 'page_view')                          as pages_viewed
    from events
    where ga_session_id is not null
    group by user_pseudo_id, ga_session_id
)

select * from sessions
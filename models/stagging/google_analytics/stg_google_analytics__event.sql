-- models/staging/google_analytics/stg_google_analytics__event.sql
with source as (
    select * from {{ source('events', 'events_20210131') }}
),

flattened as (
    select
        PARSE_DATE('%Y%m%d', event_date)                     as event_date,
        event_name,
        TIMESTAMP_MICROS(event_timestamp)                    as event_timestamp,

        -- 3 champs unnestés depuis event_params (1 ligne par event)
        (select value.int_value    from unnest(event_params) where key = 'ga_session_id') as ga_session_id,
        (select value.string_value from unnest(event_params) where key = 'page_title')    as page_title,
        (select value.string_value from unnest(event_params) where key = 'page_location') as page_location,

        user_pseudo_id,
        TIMESTAMP_MICROS(user_first_touch_timestamp)         as user_first_touch_timestamp,
        device.web_info.browser                              as browser,
        traffic_source.medium                                as traffic_medium,
        traffic_source.source                                as traffic_source,
        traffic_source.name                                  as traffic_campaign_name
    from source
)

select * from flattened

-- stg_sales_database__feedback.sql
with source as (
    select * from {{ source('sales_database', 'feedback') }}
),

renamed as (
    select
        feedback_id,                    -- clé primaire native
        order_id,
        feedback_score,
        feedback_form_sent_date,
        feedback_answer_date
    from source
)

select distinct * from renamed
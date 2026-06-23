with sessions as (

    select * from {{ ref('int_sessions') }}

),

session_aggregates as (

    select
        session_id,
        anonymous_id,
        event_date as session_date,
        min(received_at) as session_started_at,
        max(received_at) as session_ended_at,
        count(*) as event_count,
        bool_or(event_name = 'page_view') as has_page_view,
        bool_or(event_name = 'product_viewed') as has_product_viewed,
        min(case when event_name = 'product_viewed' then received_at end) as first_product_viewed_at,
        bool_or(event_name = 'cart_item_added') as has_cart_item_added,
        min(case when event_name = 'cart_item_added' then received_at end) as first_cart_add_at,
        bool_or(event_name = 'checkout_started') as has_checkout_started,
        min(case when event_name = 'checkout_started' then received_at end) as first_checkout_at,
        bool_or(event_name = 'order_completed') as has_order_completed,
        min(case when event_name = 'order_completed' then received_at end) as first_order_completed_at,
        max(case when event_name = 'checkout_started' then cart_value end) as checkout_cart_value,
        max(case when event_name = 'order_completed' then total end) as order_total,
        max(case when event_name = 'order_completed' then order_id end) as order_id,
        max(case when event_name = 'checkout_started' then email end) as checkout_email,
        max(case when event_name = 'order_completed' then email end) as order_email,
        count(case when event_name = 'product_viewed' then 1 end) as product_view_count,
        count(case when event_name = 'cart_item_added' then 1 end) as cart_add_count

    from sessions
    group by 1, 2, 3

)

select * from session_aggregates

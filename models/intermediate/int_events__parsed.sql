{{
    config(
        materialized='ephemeral'
    )
}}

select
    event_sk,
    event_id,
    anonymous_id,
    user_id,
    received_at,
    event_date,
    event_name,
    path,
    page_name,
    product_id,
    product_title,
    genre,
    price,
    quantity,
    item_count,
    cart_value,
    email,
    order_id,
    total,
    case event_name
        when 'page_view' then 1
        when 'product_viewed' then 2
        when 'cart_item_added' then 3
        when 'checkout_started' then 4
        when 'order_completed' then 5
    end as funnel_step_order

from {{ ref('stg_rudderstack__events') }}

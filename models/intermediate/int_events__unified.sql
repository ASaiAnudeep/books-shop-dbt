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
    funnel_step_order

from {{ ref('int_events__parsed') }}

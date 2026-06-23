-- Singular test: every order in fct_orders must have a matching order_completed event.

select
    orders.order_id

from {{ ref('fct_orders') }} as orders
left join {{ ref('stg_rudderstack__events') }} as events
    on orders.order_id = events.order_id
    and events.event_name = 'order_completed'
where events.event_id is null

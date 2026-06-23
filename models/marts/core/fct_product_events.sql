with events as (

    select * from {{ ref('int_sessions') }}
    where event_name in ('product_viewed', 'cart_item_added')

),

products as (

    select * from {{ ref('dim_products') }}

),

final as (

    select
        events.event_sk,
        events.session_id,
        events.anonymous_id,
        events.received_at as event_at,
        events.event_date,
        events.event_name,
        events.product_id,
        products.product_sk,
        coalesce(events.genre, products.genre) as genre,
        events.product_title,
        events.price,
        events.quantity,
        case
            when events.event_name = 'cart_item_added'
                then coalesce(events.price * events.quantity, events.price)
            else null
        end as line_value

    from events
    left join products on events.product_id = products.book_id

)

select * from final

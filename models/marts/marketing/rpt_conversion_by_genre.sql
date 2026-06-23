with product_events as (

    select * from {{ ref('fct_product_events') }}

),

sessions as (

    select * from {{ ref('int_funnel_steps') }}

),

genre_views as (

    select
        genre,
        count(*) as product_view_count

    from product_events
    where event_name = 'product_viewed'
      and genre is not null
    group by 1

),

genre_orders as (

    select
        product_events.genre,
        count(distinct sessions.session_id) as converting_sessions

    from product_events
    inner join sessions
        on product_events.session_id = sessions.session_id
        and sessions.has_order_completed
    where product_events.genre is not null
    group by 1

),

final as (

    select
        genre_views.genre,
        genre_views.product_view_count,
        coalesce(genre_orders.converting_sessions, 0) as converting_sessions,
        case
            when genre_views.product_view_count > 0
                then coalesce(genre_orders.converting_sessions, 0)::numeric
                    / genre_views.product_view_count
            else 0
        end as view_to_order_rate

    from genre_views
    left join genre_orders on genre_views.genre = genre_orders.genre

)

select * from final

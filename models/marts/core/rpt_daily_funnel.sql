with funnel as (

    select * from {{ ref('int_funnel_steps') }}

),

daily as (

    select
        session_date as report_date,
        count(*) as session_count,
        count(case when has_page_view then 1 end) as page_view_sessions,
        count(case when has_product_viewed then 1 end) as product_view_sessions,
        sum(product_view_count) as product_view_events,
        count(case when has_cart_item_added then 1 end) as cart_add_sessions,
        sum(cart_add_count) as cart_add_events,
        count(case when has_checkout_started then 1 end) as checkout_sessions,
        count(case when has_order_completed then 1 end) as order_sessions,
        sum(case when has_order_completed then order_total else 0 end) as total_revenue,
        case
            when count(*) > 0
                then count(case when has_order_completed then 1 end)::numeric / count(*)
            else 0
        end as conversion_rate

    from funnel
    group by 1

)

select * from daily

-- Ad-hoc analysis: funnel step-to-step drop-off rates by session date.
-- Run with: dbt compile && inspect target/compiled/books_shop_dbt/analyses/funnel_drop_off.sql

with funnel as (

    select * from {{ ref('int_funnel_steps') }}

),

daily_steps as (

    select
        session_date,
        count(*) as sessions,
        count(case when has_page_view then 1 end) as step_page_view,
        count(case when has_product_viewed then 1 end) as step_product_viewed,
        count(case when has_cart_item_added then 1 end) as step_cart_add,
        count(case when has_checkout_started then 1 end) as step_checkout,
        count(case when has_order_completed then 1 end) as step_order

    from funnel
    group by 1

)

select
    session_date,
    sessions,
    step_page_view,
    step_product_viewed,
    step_cart_add,
    step_checkout,
    step_order,
    round(100.0 * step_product_viewed / nullif(step_page_view, 0), 1) as pct_page_to_product,
    round(100.0 * step_cart_add / nullif(step_product_viewed, 0), 1) as pct_product_to_cart,
    round(100.0 * step_checkout / nullif(step_cart_add, 0), 1) as pct_cart_to_checkout,
    round(100.0 * step_order / nullif(step_checkout, 0), 1) as pct_checkout_to_order

from daily_steps
order by session_date

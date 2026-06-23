with orders as (

    select * from {{ ref('stg_rudderstack__events') }}
    where event_name = 'order_completed'
      and order_id is not null

),

customers as (

    select * from {{ ref('dim_customers') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['orders.order_id']) }} as order_sk,
        orders.order_id,
        orders.received_at as completed_at,
        orders.event_date as order_date,
        orders.anonymous_id,
        orders.user_id,
        customers.customer_sk,
        orders.email,
        orders.item_count,
        orders.total,
        case
            when orders.item_count > 0 then orders.total / orders.item_count
            else null
        end as avg_item_value

    from orders
    left join customers on orders.email = customers.email

)

select * from final

with source as (

    select * from {{ source('rudderstack', 'tracks') }}

    {% if is_incremental() %}
        where received_at::timestamp > (select coalesce(max(received_at), '1900-01-01'::timestamp) from {{ this }})
    {% endif %}

),

cleaned as (

    select
        event_id::text as event_id,
        anonymous_id::text as anonymous_id,
        nullif(trim(user_id::text), '') as user_id,
        received_at::timestamp as received_at,
        event_name::text as event_name,
        path::text as path,
        source::text as source,
        nullif(trim(page_name::text), '') as page_name,
        nullif(trim(product_id::text), '') as product_id,
        nullif(trim(title::text), '') as product_title,
        nullif(trim(genre::text), '') as genre,
        nullif(trim(price::text), '')::numeric as price,
        nullif(trim(quantity::text), '')::integer as quantity,
        nullif(trim(item_count::text), '')::integer as item_count,
        nullif(trim(cart_value::text), '')::numeric as cart_value,
        nullif(trim(lower(email::text)), '') as email,
        nullif(trim(order_id::text), '') as order_id,
        nullif(trim(total::text), '')::numeric as total

    from source
    where source = 'web'
      and event_name in (
          'page_view',
          'product_viewed',
          'cart_item_added',
          'checkout_started',
          'order_completed'
      )

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['event_id']) }} as event_sk,
        event_id,
        anonymous_id,
        user_id,
        received_at,
        event_name,
        path,
        source,
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
        received_at::date as event_date

    from cleaned

)

select * from final

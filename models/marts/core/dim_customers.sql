with events as (

    select * from {{ ref('stg_rudderstack__events') }}
    where email is not null

),

deduped as (

    select
        email,
        max(user_id) as user_id,
        min(received_at) as first_seen_at,
        max(received_at) as last_seen_at,
        count(distinct anonymous_id) as anonymous_id_count

    from events
    group by 1

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['email']) }} as customer_sk,
        email,
        user_id,
        first_seen_at,
        last_seen_at,
        anonymous_id_count

    from deduped

)

select * from final

with events as (

    select * from {{ ref('int_events__unified') }}

),

sessionized as (

    select
        *,
        {{ dbt_utils.generate_surrogate_key(['anonymous_id', 'event_date']) }} as session_id,
        row_number() over (
            partition by anonymous_id, event_date
            order by received_at
        ) as event_sequence_in_session

    from events

)

select * from sessionized

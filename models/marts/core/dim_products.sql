with books as (

    select * from {{ ref('stg_books_shop__books') }}

),

final as (

    select
        {{ dbt_utils.generate_surrogate_key(['book_id']) }} as product_sk,
        book_id,
        title,
        author,
        genre,
        price,
        rating,
        synopsis,
        cover_token,
        current_timestamp as loaded_at

    from books

)

select * from final

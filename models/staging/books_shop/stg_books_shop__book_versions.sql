with source as (

    select * from {{ source('books_shop', 'books_price_history') }}

),

renamed as (

    select
        book_id,
        title,
        author,
        genre,
        price::numeric as price,
        rating::numeric as rating,
        synopsis,
        cover_token,
        valid_from::date as valid_from

    from source

)

select * from renamed

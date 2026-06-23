with source as (

    select * from {{ source('books_shop', 'books') }}

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
        cover_token

    from source

)

select * from renamed

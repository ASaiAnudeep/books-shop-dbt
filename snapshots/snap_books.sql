{% snapshot snap_books %}

{{
    config(
        unique_key='book_id',
        strategy='check',
        check_cols=['price', 'rating'],
    )
}}

select
    book_id,
    title,
    author,
    genre,
    price,
    rating,
    synopsis,
    cover_token

from {{ ref('stg_books_shop__books') }}

{% endsnapshot %}

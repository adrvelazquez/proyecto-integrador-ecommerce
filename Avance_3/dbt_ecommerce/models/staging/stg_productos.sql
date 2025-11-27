with fuente as (

    select
        producto_id,
        nombre,
        descripcion,
        precio,
        stock,
        categoria_id
    from {{ source('ecommerce', 'productos') }}

)

select
    producto_id,
    nombre,
    descripcion,
    precio,
    stock,
    categoria_id
from fuente
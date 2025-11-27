with fuente as (

    select
        carrito_id,
        usuario_id,
        producto_id,
        cantidad,
        fecha_agregado
    from {{ source('ecommerce', 'carrito') }}

)

select
    carrito_id,
    usuario_id,
    producto_id,
    cantidad,
    fecha_agregado
from fuente
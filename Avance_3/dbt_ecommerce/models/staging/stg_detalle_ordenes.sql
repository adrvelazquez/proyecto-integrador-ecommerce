with fuente as (

    select
        detalle_id,
        orden_id,
        producto_id,
        cantidad,
        precio_unitario
    from {{ source('ecommerce', 'detalle_ordenes') }}

)

select
    detalle_id,
    orden_id,
    producto_id,
    cantidad,
    precio_unitario
from fuente
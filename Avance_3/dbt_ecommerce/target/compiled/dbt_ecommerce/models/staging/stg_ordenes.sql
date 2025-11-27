with fuente as (

    select
        orden_id,
        usuario_id,
        fecha_orden,
        total,
        estado
    from "EcommerceDB"."public"."ordenes"

)

select
    orden_id,
    usuario_id,
    fecha_orden,
    total,
    estado
from fuente
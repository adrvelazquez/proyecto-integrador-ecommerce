with fuente as (

    select
        metodo_pago_id,
        nombre,
        descripcion
    from "EcommerceDB"."public"."metodos_pago"

)

select
    metodo_pago_id,
    nombre,
    descripcion
from fuente
with fuente as (

    select
        categoria_id,
        nombre,
        descripcion
    from "EcommerceDB"."public"."categorias"

)

select
    categoria_id,
    nombre,
    descripcion
from fuente
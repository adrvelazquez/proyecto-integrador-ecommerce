with fuente as (

    select
        producto_id,
        nombre,
        descripcion,
        precio,
        stock,
        categoria_id
    from "EcommerceDB"."public"."productos"

)

select
    producto_id,
    nombre,
    descripcion,
    precio,
    stock,
    categoria_id
from fuente
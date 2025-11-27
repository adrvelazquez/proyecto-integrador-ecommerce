with fuente as (

    select
        usuario_id,
        nombre,
        apellido,
        dni,
        email,
        contrasena
    from "EcommerceDB"."public"."usuarios"

)

select
    usuario_id,
    nombre,
    apellido,
    dni,
    email,
    contrasena
from fuente
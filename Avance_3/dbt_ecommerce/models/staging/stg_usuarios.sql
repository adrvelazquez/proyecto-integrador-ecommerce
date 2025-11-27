with fuente as (

    select
        usuario_id,
        nombre,
        apellido,
        dni,
        email,
        contrasena
    from {{ source('ecommerce', 'usuarios') }}

)

select
    usuario_id,
    nombre,
    apellido,
    dni,
    email,
    contrasena
from fuente
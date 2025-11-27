with base as (

    select
        usuario_id,
        nombre,
        apellido,
        dni,
        email,
        contrasena
    from {{ ref('stg_usuarios') }}

),

con_clave as (

    select
        row_number() over (order by usuario_id) as usuario_key,
        usuario_id,
        nombre,
        apellido,
        dni,
        email,
        contrasena
    from base

)

select
    usuario_key,
    usuario_id,
    nombre,
    apellido,
    dni,
    email,
    contrasena
from con_clave
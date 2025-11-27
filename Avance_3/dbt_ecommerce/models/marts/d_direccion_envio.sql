with base as (

    select distinct
        direccion_id,
        usuario_id,
        calle,
        ciudad,
        departamento,
        provincia,
        distrito,
        estado,
        codigo_postal,
        pais
    from {{ ref('stg_direcciones_envio') }}

),

con_clave as (

    select
        row_number() over (order by direccion_id) as direccion_key,
        direccion_id,
        usuario_id,
        calle,
        ciudad,
        departamento,
        provincia,
        distrito,
        estado,
        codigo_postal,
        pais
    from base

)

select
    direccion_key,
    direccion_id,
    usuario_id,
    calle,
    ciudad,
    departamento,
    provincia,
    distrito,
    estado,
    codigo_postal,
    pais
from con_clave
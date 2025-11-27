with fuente as (

    select
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
    from {{ source('ecommerce', 'direcciones_envio') }}

)

select
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
from fuente
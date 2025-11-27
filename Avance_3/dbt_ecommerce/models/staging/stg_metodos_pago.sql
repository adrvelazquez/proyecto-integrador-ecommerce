with fuente as (

    select
        metodo_pago_id,
        nombre,
        descripcion
    from {{ source('ecommerce', 'metodos_pago') }}

)

select
    metodo_pago_id,
    nombre,
    descripcion
from fuente
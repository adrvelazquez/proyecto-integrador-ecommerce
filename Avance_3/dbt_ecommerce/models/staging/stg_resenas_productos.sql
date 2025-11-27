with fuente as (

    select
        resena_id,
        usuario_id,
        producto_id,
        calificacion,
        comentario,
        fecha
    from {{ source('ecommerce', 'resenas_productos') }}

)

select
    resena_id,
    usuario_id,
    producto_id,
    calificacion,
    comentario,
    fecha
from fuente
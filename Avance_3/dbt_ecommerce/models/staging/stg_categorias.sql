with fuente as (

    select
        categoria_id,
        nombre,
        descripcion
    from {{ source('ecommerce', 'categorias') }}

)

select
    categoria_id,
    nombre,
    descripcion
from fuente
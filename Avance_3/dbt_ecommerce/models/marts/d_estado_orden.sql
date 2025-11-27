with base as (

    select distinct
        estado
    from {{ ref('stg_ordenes') }}
    where estado is not null

),

con_clave as (

    select
        row_number() over (order by estado) as estado_orden_key,
        estado as codigo_estado_orden,
        estado as descripcion_estado_orden
    from base

)

select
    estado_orden_key,
    codigo_estado_orden,
    descripcion_estado_orden
from con_clave
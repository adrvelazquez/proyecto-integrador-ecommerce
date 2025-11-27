with base as (

    select distinct
        metodo_pago_id,
        nombre,
        descripcion
    from {{ ref('stg_metodos_pago') }}

),

con_clave as (

    select
        row_number() over (order by metodo_pago_id) as metodo_pago_key,
        metodo_pago_id,
        nombre       as nombre_metodo_pago,
        descripcion  as descripcion_metodo_pago
    from base

)

select
    metodo_pago_key,
    metodo_pago_id,
    nombre_metodo_pago,
    descripcion_metodo_pago
from con_clave
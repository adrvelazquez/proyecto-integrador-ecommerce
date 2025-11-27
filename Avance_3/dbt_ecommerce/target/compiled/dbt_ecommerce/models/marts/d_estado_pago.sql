with base as (

    select distinct
        estado_pago
    from "EcommerceDB"."dbt_staging"."stg_historial_pagos"
    where estado_pago is not null

),

con_clave as (

    select
        row_number() over (order by estado_pago) as estado_pago_key,
        estado_pago as codigo_estado_pago,
        estado_pago as descripcion_estado_pago
    from base

)

select
    estado_pago_key,
    codigo_estado_pago,
    descripcion_estado_pago
from con_clave
with pagos as (

    select
        historial_pago_id,
        orden_id,
        metodo_pago_id,
        monto,
        fecha_pago,
        estado_pago
    from "EcommerceDB"."dbt_staging"."stg_historial_pagos"

),

ordenes as (

    select
        orden_id,
        usuario_id
    from "EcommerceDB"."dbt_staging"."stg_ordenes"

),

usuarios_dim as (

    select
        usuario_key,
        usuario_id
    from "EcommerceDB"."dbt_marts"."d_usuario"

),

metodos_dim as (

    select
        metodo_pago_key,
        metodo_pago_id
    from "EcommerceDB"."dbt_marts"."d_metodo_pago"

),

estado_dim as (

    select
        estado_pago_key,
        codigo_estado_pago
    from "EcommerceDB"."dbt_marts"."d_estado_pago"

),

tiempo_dim as (

    select
        tiempo_key,
        fecha
    from "EcommerceDB"."dbt_marts"."d_tiempo"

),

joined as (

    select
        p.historial_pago_id,
        p.orden_id,
        u.usuario_key,
        m.metodo_pago_key,
        e.estado_pago_key,
        t.tiempo_key,
        p.monto as monto_pago
    from pagos p
    left join ordenes o
        on p.orden_id = o.orden_id
    left join usuarios_dim u
        on o.usuario_id = u.usuario_id
    left join metodos_dim m
        on p.metodo_pago_id = m.metodo_pago_id
    left join estado_dim e
        on p.estado_pago = e.codigo_estado_pago
    left join tiempo_dim t
        on date(p.fecha_pago) = t.fecha

),

con_clave as (

    select
        row_number() over (order by historial_pago_id) as pago_key,
        orden_id,
        usuario_key,
        metodo_pago_key,
        estado_pago_key,
        tiempo_key,
        monto_pago
    from joined

)

select
    pago_key,
    orden_id,
    usuario_key,
    metodo_pago_key,
    estado_pago_key,
    tiempo_key,
    monto_pago
from con_clave
with detalle as (

    select
        detalle_id,
        orden_id,
        usuario_id,
        producto_id,
        categoria_id,
        fecha_orden,
        estado_orden,
        cantidad,
        precio_unitario,
        importe_linea
    from "EcommerceDB"."dbt_interm"."int_detalle_ordenes_enriquecido"

),

usuarios_dim as (

    select
        usuario_key,
        usuario_id
    from "EcommerceDB"."dbt_marts"."d_usuario"

),

productos_dim as (

    select
        producto_key,
        producto_id,
        categoria_key
    from "EcommerceDB"."dbt_marts"."d_producto"

),

tiempo_dim as (

    select
        tiempo_key,
        fecha
    from "EcommerceDB"."dbt_marts"."d_tiempo"

),

estado_dim as (

    select
        estado_orden_key,
        codigo_estado_orden
    from "EcommerceDB"."dbt_marts"."d_estado_orden"

),

joined as (

    select
        det.detalle_id,
        det.orden_id,
        u.usuario_key,
        p.producto_key,
        p.categoria_key,
        t.tiempo_key,
        e.estado_orden_key,
        det.cantidad,
        det.precio_unitario,
        det.importe_linea
    from detalle det
    left join usuarios_dim u
        on det.usuario_id = u.usuario_id
    left join productos_dim p
        on det.producto_id = p.producto_id
    left join tiempo_dim t
        on date(det.fecha_orden) = t.fecha
    left join estado_dim e
        on det.estado_orden = e.codigo_estado_orden

),

con_clave as (

    select
        row_number() over (order by detalle_id) as detalle_orden_key,
        orden_id,
        usuario_key,
        producto_key,
        categoria_key,
        tiempo_key,
        estado_orden_key,
        cantidad,
        precio_unitario,
        importe_linea
    from joined

)

select
    detalle_orden_key,
    orden_id,
    usuario_key,
    producto_key,
    categoria_key,
    tiempo_key,
    estado_orden_key,
    cantidad,
    precio_unitario,
    importe_linea
from con_clave
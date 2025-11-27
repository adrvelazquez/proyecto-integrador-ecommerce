with ordenes as (

    select
        orden_id,
        usuario_id,
        fecha_orden,
        total,
        estado
    from {{ ref('stg_ordenes') }}

),

usuarios_dim as (

    select
        usuario_key,
        usuario_id
    from {{ ref('d_usuario') }}

),

tiempo_dim as (

    select
        tiempo_key,
        fecha
    from {{ ref('d_tiempo') }}

),

estado_dim as (

    select
        estado_orden_key,
        codigo_estado_orden
    from {{ ref('d_estado_orden') }}

),

direccion_dim as (

    select
        usuario_id,
        min(direccion_key) as direccion_key
    from {{ ref('d_direccion_envio') }}
    group by usuario_id

),

detalle_agg as (

    select
        orden_id,
        sum(cantidad) as cantidad_productos
    from {{ ref('stg_detalle_ordenes') }}
    group by orden_id

),

joined as (

    select
        o.orden_id,
        u.usuario_key,
        t.tiempo_key,
        d.direccion_key,
        e.estado_orden_key,
        o.total              as total_orden,
        coalesce(da.cantidad_productos, 0) as cantidad_productos
    from ordenes o
    left join usuarios_dim u
        on o.usuario_id = u.usuario_id
    left join tiempo_dim t
        on date(o.fecha_orden) = t.fecha
    left join direccion_dim d
        on o.usuario_id = d.usuario_id
    left join estado_dim e
        on o.estado = e.codigo_estado_orden
    left join detalle_agg da
        on o.orden_id = da.orden_id

),

con_clave as (

    select
        row_number() over (order by orden_id) as orden_key,
        orden_id,
        usuario_key,
        tiempo_key,
        direccion_key,
        estado_orden_key,
        total_orden,
        cantidad_productos
    from joined

)

select
    orden_key,
    orden_id,
    usuario_key,
    tiempo_key,
    direccion_key,
    estado_orden_key,
    total_orden,
    cantidad_productos
from con_clave
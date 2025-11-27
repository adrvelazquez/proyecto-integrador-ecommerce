/* 
=====================================================
1) Comparar cantidad de filas: interm vs fact detalle
=====================================================
*/

-- Cantidad de filas en la tabla intermedia
select count(*) as cant_interm
from dbt_interm.int_detalle_ordenes_enriquecido;

-- Cantidad de filas en la fact de detalle
select count(*) as cant_fact
from dbt_marts.f_detalle_ordenes;


/* 
=========================================
2) Chequear cobertura de claves foráneas
   en f_detalle_ordenes
=========================================
*/

select
    count(*) as total_filas,
    sum(case when usuario_key        is null then 1 else 0 end) as filas_sin_usuario,
    sum(case when producto_key       is null then 1 else 0 end) as filas_sin_producto,
    sum(case when categoria_key      is null then 1 else 0 end) as filas_sin_categoria,
    sum(case when tiempo_key         is null then 1 else 0 end) as filas_sin_tiempo,
    sum(case when estado_orden_key   is null then 1 else 0 end) as filas_sin_estado_orden
from dbt_marts.f_detalle_ordenes;


/* 
===========================================
3) Validar medidas: importe_linea consistente
===========================================
*/

select
    sum(importe_linea)                     as suma_fact,
    sum(cantidad * precio_unitario)       as suma_recalculada
from dbt_marts.f_detalle_ordenes;


/* 
===========================================================
4) Comparar totales: cabecera vs suma de líneas por orden
===========================================================
*/

-- 4.1 Cuadro comparativo de total_orden (cabecera)
--     vs total_lineas (suma de importe_linea en el detalle)
select
    o.orden_id,
    o.total_orden,
    d.total_lineas,
    (d.total_lineas - o.total_orden) as diferencia
from dbt_marts.f_ordenes o
left join (
    select
        orden_id,
        sum(importe_linea) as total_lineas
    from dbt_marts.f_detalle_ordenes
    group by orden_id
) d
    on o.orden_id = d.orden_id
order by o.orden_id;

-- 4.2 Ver solo las órdenes donde haya diferencias
--     entre cabecera y detalle
select *
from (
    select
        o.orden_id,
        o.total_orden,
        d.total_lineas,
        (d.total_lineas - o.total_orden) as diferencia
    from dbt_marts.f_ordenes o
    left join (
        select
            orden_id,
            sum(importe_linea) as total_lineas
        from dbt_marts.f_detalle_ordenes
        group by orden_id
    ) d
        on o.orden_id = d.orden_id
) x
where diferencia <> 0;

-- 4.3 Resumen: cantidad de órdenes y órdenes con diferencias


select
    count(*)                                                     as total_ordenes,
    sum(case when diferencia <> 0 then 1 else 0 end)             as ordenes_con_diferencia,
    sum(case when diferencia = 0 then 1 else 0 end)              as ordenes_sin_diferencia
from (
    select
        o.orden_id,
        o.total_orden,
        coalesce(d.total_lineas, 0) as total_lineas,
        coalesce(d.total_lineas, 0) - o.total_orden as diferencia
    from dbt_marts.f_ordenes o
    left join (
        select
            orden_id,
            sum(importe_linea) as total_lineas
        from dbt_marts.f_detalle_ordenes
        group by orden_id
    ) d
        on o.orden_id = d.orden_id
) x;



/* 
=====================================================
5) Muestreo de joins con dimensiones (sanity check)
=====================================================
*/

select
    f.orden_id,
    f.cantidad,
    f.importe_linea,
    u.nombre || ' ' || u.apellido      as nombre_usuario,
    p.nombre_producto,
    c.nombre_categoria,
    t.fecha,
    eo.descripcion_estado_orden
from dbt_marts.f_detalle_ordenes f
left join dbt_marts.d_usuario       u  on f.usuario_key      = u.usuario_key
left join dbt_marts.d_producto      p  on f.producto_key     = p.producto_key
left join dbt_marts.d_categoria     c  on f.categoria_key    = c.categoria_key
left join dbt_marts.d_tiempo        t  on f.tiempo_key       = t.tiempo_key
left join dbt_marts.d_estado_orden  eo on f.estado_orden_key = eo.estado_orden_key
limit 20;
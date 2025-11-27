
  
    

  create  table "EcommerceDB"."dbt_interm"."int_detalle_ordenes_enriquecido__dbt_tmp"
  
  
    as
  
  (
    with detalle as (

    select
        d.detalle_id,
        d.orden_id,
        d.producto_id,
        d.cantidad,
        d.precio_unitario,
        d.cantidad * d.precio_unitario as importe_linea
    from "EcommerceDB"."dbt_staging"."stg_detalle_ordenes" as d

),

ordenes as (

    select
        o.orden_id,
        o.usuario_id,
        o.fecha_orden,
        o.total,
        o.estado
    from "EcommerceDB"."dbt_staging"."stg_ordenes" as o

),

productos as (

    select
        p.producto_id,
        p.categoria_id
    from "EcommerceDB"."dbt_staging"."stg_productos" as p

)

select
    det.detalle_id,
    det.orden_id,
    ord.usuario_id,
    det.producto_id,
    prod.categoria_id,
    ord.fecha_orden,
    ord.estado as estado_orden,
    det.cantidad,
    det.precio_unitario,
    det.importe_linea,
    ord.total as total_orden
from detalle det
left join ordenes ord
    on det.orden_id = ord.orden_id
left join productos prod
    on det.producto_id = prod.producto_id
  );
  
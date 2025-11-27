
  create view "EcommerceDB"."dbt_staging"."stg_detalle_ordenes__dbt_tmp"
    
    
  as (
    with fuente as (

    select
        detalle_id,
        orden_id,
        producto_id,
        cantidad,
        precio_unitario
    from "EcommerceDB"."public"."detalle_ordenes"

)

select
    detalle_id,
    orden_id,
    producto_id,
    cantidad,
    precio_unitario
from fuente
  );

  create view "EcommerceDB"."dbt_staging"."stg_carrito__dbt_tmp"
    
    
  as (
    with fuente as (

    select
        carrito_id,
        usuario_id,
        producto_id,
        cantidad,
        fecha_agregado
    from "EcommerceDB"."public"."carrito"

)

select
    carrito_id,
    usuario_id,
    producto_id,
    cantidad,
    fecha_agregado
from fuente
  );
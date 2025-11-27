
  create view "EcommerceDB"."dbt_staging"."stg_ordenes__dbt_tmp"
    
    
  as (
    with fuente as (

    select
        orden_id,
        usuario_id,
        fecha_orden,
        total,
        estado
    from "EcommerceDB"."public"."ordenes"

)

select
    orden_id,
    usuario_id,
    fecha_orden,
    total,
    estado
from fuente
  );
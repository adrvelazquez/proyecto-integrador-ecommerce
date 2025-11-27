
  create view "EcommerceDB"."dbt_staging"."stg_resenas_productos__dbt_tmp"
    
    
  as (
    with fuente as (

    select
        resena_id,
        usuario_id,
        producto_id,
        calificacion,
        comentario,
        fecha
    from "EcommerceDB"."public"."resenas_productos"

)

select
    resena_id,
    usuario_id,
    producto_id,
    calificacion,
    comentario,
    fecha
from fuente
  );
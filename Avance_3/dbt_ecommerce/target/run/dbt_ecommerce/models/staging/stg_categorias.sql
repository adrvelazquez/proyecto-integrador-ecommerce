
  create view "EcommerceDB"."dbt_staging"."stg_categorias__dbt_tmp"
    
    
  as (
    with fuente as (

    select
        categoria_id,
        nombre,
        descripcion
    from "EcommerceDB"."public"."categorias"

)

select
    categoria_id,
    nombre,
    descripcion
from fuente
  );
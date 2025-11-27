
  
    

  create  table "EcommerceDB"."dbt_marts"."d_categoria__dbt_tmp"
  
  
    as
  
  (
    with base as (

    select distinct
        categoria_id,
        nombre,
        descripcion
    from "EcommerceDB"."dbt_staging"."stg_categorias"

),

con_clave as (

    select
        row_number() over (order by categoria_id) as categoria_key,
        categoria_id,
        nombre        as nombre_categoria,
        descripcion   as descripcion_categoria
    from base

)

select
    categoria_key,
    categoria_id,
    nombre_categoria,
    descripcion_categoria
from con_clave
  );
  
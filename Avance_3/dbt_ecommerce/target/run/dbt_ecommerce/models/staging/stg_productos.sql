
  create view "EcommerceDB"."dbt_staging"."stg_productos__dbt_tmp"
    
    
  as (
    with fuente as (

    select
        producto_id,
        nombre,
        descripcion,
        precio,
        stock,
        categoria_id
    from "EcommerceDB"."public"."productos"

)

select
    producto_id,
    nombre,
    descripcion,
    precio,
    stock,
    categoria_id
from fuente
  );
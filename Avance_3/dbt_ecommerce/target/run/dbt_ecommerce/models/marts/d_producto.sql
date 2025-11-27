
  
    

  create  table "EcommerceDB"."dbt_marts"."d_producto__dbt_tmp"
  
  
    as
  
  (
    with productos as (

    select
        producto_id,
        nombre,
        descripcion,
        precio,
        stock,
        categoria_id
    from "EcommerceDB"."dbt_staging"."stg_productos"

),

categorias as (

    select
        categoria_key,
        categoria_id
    from "EcommerceDB"."dbt_marts"."d_categoria"

),

joined as (

    select
        p.producto_id,
        p.nombre,
        p.descripcion,
        p.precio,
        p.stock,
        p.categoria_id,
        c.categoria_key
    from productos p
    left join categorias c
        on p.categoria_id = c.categoria_id

),

con_clave as (

    select
        row_number() over (order by producto_id) as producto_key,
        producto_id,
        nombre        as nombre_producto,
        descripcion   as descripcion_producto,
        precio,
        stock,
        categoria_key,
        categoria_id
    from joined

)

select
    producto_key,
    producto_id,
    nombre_producto,
    descripcion_producto,
    precio,
    stock,
    categoria_key,
    categoria_id
from con_clave
  );
  
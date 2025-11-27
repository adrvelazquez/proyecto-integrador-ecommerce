
  
    

  create  table "EcommerceDB"."dbt_marts"."f_carrito__dbt_tmp"
  
  
    as
  
  (
    with carrito as (

    select
        carrito_id,
        usuario_id,
        producto_id,
        cantidad,
        fecha_agregado
    from "EcommerceDB"."dbt_staging"."stg_carrito"

),

usuarios_dim as (

    select
        usuario_key,
        usuario_id
    from "EcommerceDB"."dbt_marts"."d_usuario"

),

productos_dim as (

    select
        producto_key,
        producto_id,
        categoria_key
    from "EcommerceDB"."dbt_marts"."d_producto"

),

tiempo_dim as (

    select
        tiempo_key,
        fecha
    from "EcommerceDB"."dbt_marts"."d_tiempo"

),

joined as (

    select
        c.carrito_id,
        u.usuario_key,
        p.producto_key,
        p.categoria_key,
        t.tiempo_key,
        c.cantidad
    from carrito c
    left join usuarios_dim u
        on c.usuario_id = u.usuario_id
    left join productos_dim p
        on c.producto_id = p.producto_id
    left join tiempo_dim t
        on date(c.fecha_agregado) = t.fecha

),

con_clave as (

    select
        row_number() over (order by carrito_id) as carrito_key,
        usuario_key,
        producto_key,
        categoria_key,
        tiempo_key,
        cantidad
    from joined

)

select
    carrito_key,
    usuario_key,
    producto_key,
    categoria_key,
    tiempo_key,
    cantidad
from con_clave
  );
  
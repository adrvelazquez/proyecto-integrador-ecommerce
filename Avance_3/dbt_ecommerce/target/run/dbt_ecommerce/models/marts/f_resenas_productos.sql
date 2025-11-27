
  
    

  create  table "EcommerceDB"."dbt_marts"."f_resenas_productos__dbt_tmp"
  
  
    as
  
  (
    with resenas as (

    select
        resena_id,
        usuario_id,
        producto_id,
        calificacion,
        comentario,
        fecha
    from "EcommerceDB"."dbt_staging"."stg_resenas_productos"

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
        r.resena_id,
        u.usuario_key,
        p.producto_key,
        p.categoria_key,
        t.tiempo_key,
        r.calificacion
    from resenas r
    left join usuarios_dim u
        on r.usuario_id = u.usuario_id
    left join productos_dim p
        on r.producto_id = p.producto_id
    left join tiempo_dim t
        on date(r.fecha) = t.fecha

),

con_clave as (

    select
        row_number() over (order by resena_id) as resena_key,
        usuario_key,
        producto_key,
        categoria_key,
        tiempo_key,
        calificacion
    from joined

)

select
    resena_key,
    usuario_key,
    producto_key,
    categoria_key,
    tiempo_key,
    calificacion
from con_clave
  );
  
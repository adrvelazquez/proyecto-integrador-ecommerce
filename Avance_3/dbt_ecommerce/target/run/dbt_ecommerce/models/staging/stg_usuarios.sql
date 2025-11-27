
  create view "EcommerceDB"."dbt_staging"."stg_usuarios__dbt_tmp"
    
    
  as (
    with fuente as (

    select
        usuario_id,
        nombre,
        apellido,
        dni,
        email,
        contrasena
    from "EcommerceDB"."public"."usuarios"

)

select
    usuario_id,
    nombre,
    apellido,
    dni,
    email,
    contrasena
from fuente
  );

  create view "EcommerceDB"."dbt_staging"."stg_metodos_pago__dbt_tmp"
    
    
  as (
    with fuente as (

    select
        metodo_pago_id,
        nombre,
        descripcion
    from "EcommerceDB"."public"."metodos_pago"

)

select
    metodo_pago_id,
    nombre,
    descripcion
from fuente
  );
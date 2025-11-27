
  create view "EcommerceDB"."dbt_staging"."stg_ordenes_metodospago__dbt_tmp"
    
    
  as (
    with fuente as (

    select
        orden_metodo_pago_id,
        orden_id,
        metodo_pago_id,
        monto_pagado
    from "EcommerceDB"."public"."ordenes_metodospago"

)

select
    orden_metodo_pago_id,
    orden_id,
    metodo_pago_id,
    monto_pagado
from fuente
  );
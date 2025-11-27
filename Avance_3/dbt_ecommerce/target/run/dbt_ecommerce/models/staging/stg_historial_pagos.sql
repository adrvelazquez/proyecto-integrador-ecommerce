
  create view "EcommerceDB"."dbt_staging"."stg_historial_pagos__dbt_tmp"
    
    
  as (
    with fuente as (

    select
        historial_pago_id,
        orden_id,
        metodo_pago_id,
        monto,
        fecha_pago,
        estado_pago
    from "EcommerceDB"."public"."historial_pagos"

)

select
    historial_pago_id,
    orden_id,
    metodo_pago_id,
    monto,
    fecha_pago,
    estado_pago
from fuente
  );
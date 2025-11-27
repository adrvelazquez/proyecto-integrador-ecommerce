with fuente as (

    select
        historial_pago_id,
        orden_id,
        metodo_pago_id,
        monto,
        fecha_pago,
        estado_pago
    from {{ source('ecommerce', 'historial_pagos') }}

)

select
    historial_pago_id,
    orden_id,
    metodo_pago_id,
    monto,
    fecha_pago,
    estado_pago
from fuente
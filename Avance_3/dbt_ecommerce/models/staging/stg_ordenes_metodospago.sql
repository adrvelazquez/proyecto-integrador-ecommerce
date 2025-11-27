with fuente as (

    select
        orden_metodo_pago_id,
        orden_id,
        metodo_pago_id,
        monto_pagado
    from {{ source('ecommerce', 'ordenes_metodospago') }}

)

select
    orden_metodo_pago_id,
    orden_id,
    metodo_pago_id,
    monto_pagado
from fuente
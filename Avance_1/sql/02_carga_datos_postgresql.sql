-- ============================================
-- CARGA DE DATOS DESDE CSV A TABLAS POSTGRESQL
-- Proyecto Integrador - Comercio Electrónico
-- Base: EcommerceDB
-- ============================================

-- 1) USUARIOS
COPY usuarios (nombre, apellido, dni, email, contrasena)
FROM 'C:/pg_ecommerce/data_raw/1.Usuarios.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 2) CATEGORÍAS
COPY categorias (nombre, descripcion)
FROM 'C:/pg_ecommerce/data_raw/2.Categorias.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 3) MÉTODOS DE PAGO
COPY metodos_pago (nombre, descripcion)
FROM 'C:/pg_ecommerce/data_raw/8.metodos_pago.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 4) PRODUCTOS
COPY productos (nombre, descripcion, precio, stock, categoria_id)
FROM 'C:/pg_ecommerce/data_raw/3.Productos.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 5) ÓRDENES
COPY ordenes (usuario_id, fecha_orden, total, estado)
FROM 'C:/pg_ecommerce/data_raw/4.ordenes.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 6) DETALLE DE ÓRDENES
COPY detalle_ordenes (orden_id, producto_id, cantidad, precio_unitario)
FROM 'C:/pg_ecommerce/data_raw/5.detalle_ordenes.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 7) DIRECCIONES DE ENVÍO
COPY direcciones_envio (
    usuario_id,
    calle,
    ciudad,
    departamento,
    provincia,
    distrito,
    estado,
    codigo_postal,
    pais
)
FROM 'C:/pg_ecommerce/data_raw/6.direcciones_envio.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 8) CARRITO
COPY carrito (usuario_id, producto_id, cantidad, fecha_agregado)
FROM 'C:/pg_ecommerce/data_raw/7.carrito.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 9) ÓRDENES - MÉTODOS DE PAGO
COPY ordenes_metodospago (orden_id, metodo_pago_id, monto_pagado)
FROM 'C:/pg_ecommerce/data_raw/9.ordenes_metodospago.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 10) RESEÑAS DE PRODUCTOS
COPY resenas_productos (
    usuario_id,
    producto_id,
    calificacion,
    comentario,
    fecha
)
FROM 'C:/pg_ecommerce/data_raw/10.resenas_productos.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

-- 11) HISTORIAL DE PAGOS
COPY historial_pagos (
    orden_id,
    metodo_pago_id,
    monto,
    fecha_pago,
    estado_pago
)
FROM 'C:/pg_ecommerce/data_raw/11.historial_pagos.csv'
DELIMITER ','
CSV HEADER
ENCODING 'UTF8';

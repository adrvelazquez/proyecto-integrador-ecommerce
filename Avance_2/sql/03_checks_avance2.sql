-- =======================
-- Dimensiones
-- =======================

-- Usuarios / clientes
SELECT * FROM avance2.d_usuario LIMIT 5;

-- Categorías de productos
SELECT * FROM avance2.d_categoria LIMIT 5;

-- Productos
SELECT * FROM avance2.d_producto LIMIT 5;

-- Tiempo / calendario
SELECT * FROM avance2.d_tiempo LIMIT 5;

-- Direcciones de envío / geografía
SELECT * FROM avance2.d_direccion_envio LIMIT 5;

-- Métodos de pago
SELECT * FROM avance2.d_metodo_pago LIMIT 5;

-- Estados de orden
SELECT * FROM avance2.d_estado_orden LIMIT 5;

-- Estados de pago
SELECT * FROM avance2.d_estado_pago LIMIT 5;


-- =======================
-- Hechos
-- =======================

-- Órdenes (cabecera)
SELECT * FROM avance2.f_ordenes LIMIT 5;

-- Detalle de órdenes (líneas)
SELECT * FROM avance2.f_detalle_ordenes LIMIT 5;

-- Pagos
SELECT * FROM avance2.f_pagos LIMIT 5;

-- Reseñas de productos
SELECT * FROM avance2.f_resenas_productos LIMIT 5;

-- Carrito
SELECT * FROM avance2.f_carrito LIMIT 5;
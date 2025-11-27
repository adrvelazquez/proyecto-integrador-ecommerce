-- =======================================================
-- 03_exploracion_sql_basica.sql
-- Proyecto Integrador - Avance 1
-- Exploración y chequeos de calidad con SQL en EcommerceDB
-- =======================================================

-- 1) Cantidad de registros por tabla
SELECT 'usuarios'              AS tabla, COUNT(*) AS total FROM usuarios
UNION ALL
SELECT 'categorias',                  COUNT(*) FROM categorias
UNION ALL
SELECT 'productos',                   COUNT(*) FROM productos
UNION ALL
SELECT 'metodos_pago',                COUNT(*) FROM metodos_pago
UNION ALL
SELECT 'ordenes',                     COUNT(*) FROM ordenes
UNION ALL
SELECT 'detalle_ordenes',             COUNT(*) FROM detalle_ordenes
UNION ALL
SELECT 'direcciones_envio',           COUNT(*) FROM direcciones_envio
UNION ALL
SELECT 'carrito',                     COUNT(*) FROM carrito
UNION ALL
SELECT 'ordenes_metodospago',         COUNT(*) FROM ordenes_metodospago
UNION ALL
SELECT 'resenas_productos',           COUNT(*) FROM resenas_productos
UNION ALL
SELECT 'historial_pagos',             COUNT(*) FROM historial_pagos
;

-- 2) Usuarios: nulos y duplicados básicos
-- 2.1 ¿Hay nulos en campos importantes?
SELECT
    COUNT(*) AS total_usuarios,
    COUNT(*) FILTER (WHERE nombre IS NULL)      AS n_nombre_nulos,
    COUNT(*) FILTER (WHERE apellido IS NULL)    AS n_apellido_nulos,
    COUNT(*) FILTER (WHERE dni IS NULL)         AS n_dni_nulos,
    COUNT(*) FILTER (WHERE email IS NULL)       AS n_email_nulos
FROM usuarios;

-- 2.2 ¿Hay DNIs o emails duplicados?
SELECT 'dni' AS campo, dni::text AS valor, COUNT(*) AS cantidad
FROM usuarios
GROUP BY dni
HAVING COUNT(*) > 1

UNION ALL

SELECT 'email' AS campo, email AS valor, COUNT(*) AS cantidad
FROM usuarios
GROUP BY email
HAVING COUNT(*) > 1
;

-- 3) Productos: precios, stock y nulos
-- 3.1 Nulos
SELECT
    COUNT(*) AS total_productos,
    COUNT(*) FILTER (WHERE nombre IS NULL)        AS n_nombre_nulos,
    COUNT(*) FILTER (WHERE precio IS NULL)        AS n_precio_nulos,
    COUNT(*) FILTER (WHERE stock IS NULL)         AS n_stock_nulos,
    COUNT(*) FILTER (WHERE categoria_id IS NULL)  AS n_categoriaid_nulos
FROM productos;

-- 3.2 Rango de precios y stock
SELECT
    MIN(precio) AS min_precio,
    MAX(precio) AS max_precio,
    AVG(precio) AS avg_precio,
    MIN(stock)  AS min_stock,
    MAX(stock)  AS max_stock,
    AVG(stock)  AS avg_stock
FROM productos;

-- 3.3 ¿Productos sin categoría válida?
SELECT COUNT(*) AS productos_sin_categoria_valida
FROM productos p
LEFT JOIN categorias c ON p.categoria_id = c.categoria_id
WHERE c.categoria_id IS NULL;

-- 4) Ordenes: fechas, montos y estados
-- 4.1 Rango de fechas y totales
SELECT
    COUNT(*)      AS total_ordenes,
    MIN(fecha_orden) AS min_fecha_orden,
    MAX(fecha_orden) AS max_fecha_orden,
    MIN(total)    AS min_total,
    MAX(total)    AS max_total,
    AVG(total)    AS avg_total
FROM ordenes;

-- 4.2 ¿Órdenes con usuario inexistente?
SELECT COUNT(*) AS ordenes_sin_usuario_valido
FROM ordenes o
LEFT JOIN usuarios u ON o.usuario_id = u.usuario_id
WHERE u.usuario_id IS NULL;

-- 4.3 Distribución de órdenes por estado
SELECT estado, COUNT(*) AS cantidad
FROM ordenes
GROUP BY estado
ORDER BY cantidad DESC;

-- 5) Detalle de órdenes: integridad con órdenes y productos
-- 5.1 ¿Detalles con orden inexistente?
SELECT COUNT(*) AS detalles_sin_orden_valida
FROM detalle_ordenes d
LEFT JOIN ordenes o ON d.orden_id = o.orden_id
WHERE o.orden_id IS NULL;

-- 5.2 ¿Detalles con producto inexistente?
SELECT COUNT(*) AS detalles_sin_producto_valido
FROM detalle_ordenes d
LEFT JOIN productos p ON d.producto_id = p.producto_id
WHERE p.producto_id IS NULL;

-- 6) Direcciones: nulos básicos
SELECT
    COUNT(*) AS total_direcciones,
    COUNT(*) FILTER (WHERE usuario_id IS NULL) AS n_usuarioid_nulos,
    COUNT(*) FILTER (WHERE calle IS NULL)      AS n_calle_nulos,
    COUNT(*) FILTER (WHERE ciudad IS NULL)     AS n_ciudad_nulos,
    COUNT(*) FILTER (WHERE provincia IS NULL)  AS n_provincia_nulos,
    COUNT(*) FILTER (WHERE pais IS NULL)       AS n_pais_nulos
FROM direcciones_envio;

-- 7) Carrito: integridad básica
SELECT COUNT(*) AS filas_carrito FROM carrito;

-- 7.1 ¿Carrito con usuario inexistente?
SELECT COUNT(*) AS carrito_sin_usuario_valido
FROM carrito c
LEFT JOIN usuarios u ON c.usuario_id = u.usuario_id
WHERE u.usuario_id IS NULL;

-- 7.2 ¿Carrito con producto inexistente?
SELECT COUNT(*) AS carrito_sin_producto_valido
FROM carrito c
LEFT JOIN productos p ON c.producto_id = p.producto_id
WHERE p.producto_id IS NULL;

-- 8) Métodos de pago y relaciones con órdenes
-- 8.1 Cantidad de métodos de pago
SELECT COUNT(*) AS total_metodos_pago FROM metodos_pago;

-- 8.2 Órdenes_metodospago: integridad
SELECT
    COUNT(*) AS total_ordenes_metodospago,
    COUNT(*) FILTER (
        WHERE o.orden_id IS NULL
    ) AS filas_sin_orden_valida,
    COUNT(*) FILTER (
        WHERE m.metodo_pago_id IS NULL
    ) AS filas_sin_metodo_pago_valido
FROM ordenes_metodospago omp
LEFT JOIN ordenes o       ON omp.orden_id      = o.orden_id
LEFT JOIN metodos_pago m  ON omp.metodo_pago_id = m.metodo_pago_id;

-- 9) Reseñas de productos: integridad + nulos
SELECT
    COUNT(*) AS total_resenas,
    COUNT(*) FILTER (WHERE usuario_id IS NULL)   AS n_usuarioid_nulos,
    COUNT(*) FILTER (WHERE producto_id IS NULL)  AS n_productoid_nulos,
    COUNT(*) FILTER (WHERE calificacion IS NULL) AS n_calificacion_nulos,
    COUNT(*) FILTER (WHERE fecha IS NULL)        AS n_fecha_nulos
FROM resenas_productos;

-- 9.1 ¿Reseñas con usuario o producto inexistente?
SELECT
    COUNT(*) FILTER (WHERE u.usuario_id IS NULL)  AS resenas_sin_usuario_valido,
    COUNT(*) FILTER (WHERE p.producto_id IS NULL) AS resenas_sin_producto_valido
FROM resenas_productos r
LEFT JOIN usuarios  u ON r.usuario_id  = u.usuario_id
LEFT JOIN productos p ON r.producto_id = p.producto_id;

-- 10) Historial de pagos: integridad con órdenes y métodos de pago
SELECT
    COUNT(*) AS total_historial,
    COUNT(*) FILTER (WHERE o.orden_id IS NULL)      AS pagos_sin_orden_valida,
    COUNT(*) FILTER (WHERE m.metodo_pago_id IS NULL) AS pagos_sin_metodopago_valido
FROM historial_pagos h
LEFT JOIN ordenes      o ON h.orden_id      = o.orden_id
LEFT JOIN metodos_pago m ON h.metodo_pago_id = m.metodo_pago_id;

-- 11) Rango de fechas de pagos y montos
SELECT
    MIN(fecha_pago) AS min_fecha_pago,
    MAX(fecha_pago) AS max_fecha_pago,
    MIN(monto)      AS min_monto,
    MAX(monto)      AS max_monto,
    AVG(monto)      AS avg_monto
FROM historial_pagos;
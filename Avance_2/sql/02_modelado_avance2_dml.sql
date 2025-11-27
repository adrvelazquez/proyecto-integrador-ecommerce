-- ==========================================
-- Avance 2 - Modelado de datos
-- Script: 02_modelado_avance2_dml.sql
-- Descripción:
--   - Poblado de dimensiones y hechos en esquema avance2
--     a partir de las tablas originales en public.
-- ==========================================

-- Trabajamos priorizando avance2 y luego public
SET search_path TO avance2, public;

-- ==========================================
-- 0) Limpieza previa (para poder re-ejecutar)
-- ==========================================

TRUNCATE TABLE
    avance2.f_carrito,
    avance2.f_resenas_productos,
    avance2.f_pagos,
    avance2.f_detalle_ordenes,
    avance2.f_ordenes,
    avance2.d_estado_pago,
    avance2.d_estado_orden,
    avance2.d_metodo_pago,
    avance2.d_direccion_envio,
    avance2.d_tiempo,
    avance2.d_producto,
    avance2.d_categoria,
    avance2.d_usuario
RESTART IDENTITY CASCADE;


-- ==========================================
-- 1) DIMENSIONES
-- ==========================================

-- 1.1 Dimensión de usuarios / clientes (d_usuario)
INSERT INTO avance2.d_usuario (
    usuario_id,
    nombre,
    apellido,
    dni,
    email,
    contrasena
)
SELECT
    u.usuario_id,
    u.nombre,
    u.apellido,
    u.dni,
    u.email,
    u.contrasena
FROM public.usuarios AS u;


-- 1.2 Dimensión de categorías (d_categoria)
INSERT INTO avance2.d_categoria (
    categoria_id,
    nombre_categoria,
    descripcion_categoria
)
SELECT
    c.categoria_id,
    c.nombre,
    c.descripcion
FROM public.categorias AS c;


-- 1.3 Dimensión de productos (d_producto)
INSERT INTO avance2.d_producto (
    producto_id,
    nombre_producto,
    descripcion_producto,
    precio,
    stock,
    categoria_key,
    categoria_id
)
SELECT
    p.producto_id,
    p.nombre,
    p.descripcion,
    p.precio,
    p.stock,
    dc.categoria_key,
    p.categoria_id
FROM public.productos AS p
LEFT JOIN avance2.d_categoria AS dc
    ON dc.categoria_id = p.categoria_id;


-- 1.4 Dimensión de tiempo (d_tiempo)
-- Se construye a partir de todas las fechas presentes en órdenes, pagos, reseñas y carrito.
WITH fechas_raw AS (
    SELECT DATE(o.fecha_orden) AS fecha
    FROM public.ordenes AS o
    UNION
    SELECT DATE(hp.fecha_pago) AS fecha
    FROM public.historial_pagos AS hp
    UNION
    SELECT DATE(rp.fecha) AS fecha
    FROM public.resenas_productos AS rp
    UNION
    SELECT DATE(ca.fecha_agregado) AS fecha
    FROM public.carrito AS ca
),
fechas_distintas AS (
    SELECT DISTINCT fecha
    FROM fechas_raw
)
INSERT INTO avance2.d_tiempo (
    fecha,
    anio,
    mes,
    nombre_mes,
    trimestre,
    dia_semana,
    nombre_dia_semana
)
SELECT
    f.fecha,
    EXTRACT(YEAR  FROM f.fecha)::INT AS anio,
    EXTRACT(MONTH FROM f.fecha)::INT AS mes,
    TO_CHAR(f.fecha, 'TMMonth')      AS nombre_mes,
    EXTRACT(QUARTER FROM f.fecha)::INT AS trimestre,
    EXTRACT(DOW FROM f.fecha)::INT   AS dia_semana,   -- 0=domingo, 1=lunes, ...
    TO_CHAR(f.fecha, 'TMDay')        AS nombre_dia_semana
FROM fechas_distintas AS f
ORDER BY f.fecha;


-- 1.5 Dimensión de direcciones de envío (d_direccion_envio)
INSERT INTO avance2.d_direccion_envio (
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
SELECT DISTINCT
    de.usuario_id,
    de.calle,
    de.ciudad,
    de.departamento,
    de.provincia,
    de.distrito,
    de.estado,
    de.codigo_postal,
    de.pais
FROM public.direcciones_envio AS de;


-- 1.6 Dimensión de métodos de pago (d_metodo_pago)
INSERT INTO avance2.d_metodo_pago (
    metodo_pago_id,
    nombre_metodo_pago,
    descripcion_metodo_pago
)
SELECT
    mp.metodo_pago_id,
    mp.nombre,
    mp.descripcion
FROM public.metodos_pago AS mp;


-- 1.7 Dimensión de estados de orden (d_estado_orden)
INSERT INTO avance2.d_estado_orden (
    codigo_estado_orden,
    descripcion_estado_orden
)
SELECT DISTINCT
    o.estado AS codigo_estado_orden,
    o.estado AS descripcion_estado_orden
FROM public.ordenes AS o
WHERE o.estado IS NOT NULL;


-- 1.8 Dimensión de estados de pago (d_estado_pago)
INSERT INTO avance2.d_estado_pago (
    codigo_estado_pago,
    descripcion_estado_pago
)
SELECT DISTINCT
    hp.estado_pago AS codigo_estado_pago,
    hp.estado_pago AS descripcion_estado_pago
FROM public.historial_pagos AS hp
WHERE hp.estado_pago IS NOT NULL;


-- ==========================================
-- 2) TABLAS DE HECHOS
-- ==========================================

-- Para evitar duplicidades por direcciones, elegimos una única
-- dirección "principal" por usuario (por ejemplo, la de menor direccion_key).
WITH direccion_principal AS (
    SELECT
        usuario_id,
        MIN(direccion_key) AS direccion_key
    FROM avance2.d_direccion_envio
    GROUP BY usuario_id
),

-- Cantidad total de ítems por orden, desde detalle_ordenes
items_por_orden AS (
    SELECT
        d.orden_id,
        SUM(d.cantidad) AS cantidad_items
    FROM public.detalle_ordenes AS d
    GROUP BY d.orden_id
)

-- 2.1 Hecho de Órdenes (f_ordenes)
INSERT INTO avance2.f_ordenes (
    orden_id,
    usuario_key,
    tiempo_key,
    direccion_key,
    estado_orden_key,
    total_orden,
    cantidad_productos
)
SELECT
    o.orden_id,
    du.usuario_key,
    dt.tiempo_key,
    dp.direccion_key,
    deo.estado_orden_key,
    o.total,
    COALESCE(io.cantidad_items, 0) AS cantidad_productos
FROM public.ordenes AS o
JOIN avance2.d_usuario AS du
    ON du.usuario_id = o.usuario_id
JOIN avance2.d_tiempo AS dt
    ON dt.fecha = DATE(o.fecha_orden)
LEFT JOIN direccion_principal AS dp
    ON dp.usuario_id = o.usuario_id
LEFT JOIN avance2.d_estado_orden AS deo
    ON deo.codigo_estado_orden = o.estado
LEFT JOIN items_por_orden AS io
    ON io.orden_id = o.orden_id;


-- 2.2 Hecho de Detalle de Órdenes (f_detalle_ordenes)
INSERT INTO avance2.f_detalle_ordenes (
    orden_id,
    usuario_key,
    producto_key,
    categoria_key,
    tiempo_key,
    estado_orden_key,
    cantidad,
    precio_unitario,
    importe_linea
)
SELECT
    d.orden_id,
    du.usuario_key,
    dp.producto_key,
    dp.categoria_key,
    dt.tiempo_key,
    deo.estado_orden_key,
    d.cantidad,
    d.precio_unitario,
    d.cantidad * d.precio_unitario AS importe_linea
FROM public.detalle_ordenes AS d
JOIN public.ordenes AS o
    ON o.orden_id = d.orden_id
JOIN avance2.d_usuario AS du
    ON du.usuario_id = o.usuario_id
JOIN avance2.d_producto AS dp
    ON dp.producto_id = d.producto_id
JOIN avance2.d_tiempo AS dt
    ON dt.fecha = DATE(o.fecha_orden)
LEFT JOIN avance2.d_estado_orden AS deo
    ON deo.codigo_estado_orden = o.estado;


-- 2.3 Hecho de Pagos (f_pagos)
-- Usamos historial_pagos como base y, si existe,
-- tomamos monto_pagado de ordenes_metodospago.
INSERT INTO avance2.f_pagos (
    orden_id,
    usuario_key,
    metodo_pago_key,
    estado_pago_key,
    tiempo_key,
    monto_pago
)
SELECT
    hp.orden_id,
    du.usuario_key,
    dmp.metodo_pago_key,
    dep.estado_pago_key,
    dt.tiempo_key,
    COALESCE(omp.monto_pagado, hp.monto) AS monto_pago
FROM public.historial_pagos AS hp
LEFT JOIN public.ordenes AS o
    ON o.orden_id = hp.orden_id
LEFT JOIN avance2.d_usuario AS du
    ON du.usuario_id = o.usuario_id
JOIN avance2.d_metodo_pago AS dmp
    ON dmp.metodo_pago_id = hp.metodo_pago_id
LEFT JOIN public.ordenes_metodospago AS omp
    ON omp.orden_id = hp.orden_id
   AND omp.metodo_pago_id = hp.metodo_pago_id
LEFT JOIN avance2.d_estado_pago AS dep
    ON dep.codigo_estado_pago = hp.estado_pago
JOIN avance2.d_tiempo AS dt
    ON dt.fecha = DATE(hp.fecha_pago);


-- 2.4 Hecho de Reseñas de Productos (f_resenas_productos)
INSERT INTO avance2.f_resenas_productos (
    usuario_key,
    producto_key,
    categoria_key,
    tiempo_key,
    calificacion
)
SELECT
    du.usuario_key,
    dp.producto_key,
    dp.categoria_key,
    dt.tiempo_key,
    rp.calificacion
FROM public.resenas_productos AS rp
JOIN public.usuarios AS u
    ON u.usuario_id = rp.usuario_id
JOIN avance2.d_usuario AS du
    ON du.usuario_id = u.usuario_id
JOIN avance2.d_producto AS dp
    ON dp.producto_id = rp.producto_id
JOIN avance2.d_tiempo AS dt
    ON dt.fecha = DATE(rp.fecha);


-- 2.5 Hecho de Carrito (f_carrito)
INSERT INTO avance2.f_carrito (
    usuario_key,
    producto_key,
    categoria_key,
    tiempo_key,
    cantidad
)
SELECT
    du.usuario_key,
    dp.producto_key,
    dp.categoria_key,
    dt.tiempo_key,
    ca.cantidad
FROM public.carrito AS ca
JOIN public.usuarios AS u
    ON u.usuario_id = ca.usuario_id
JOIN avance2.d_usuario AS du
    ON du.usuario_id = u.usuario_id
JOIN avance2.d_producto AS dp
    ON dp.producto_id = ca.producto_id
JOIN avance2.d_tiempo AS dt
    ON dt.fecha = DATE(ca.fecha_agregado);
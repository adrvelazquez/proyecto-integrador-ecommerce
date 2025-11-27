-- ==========================================
-- Avance 2 - Modelado de datos
-- Script: 01_modelado_avance2_ddl.sql
-- Descripción:
--   - Creación del esquema avance2
--   - Creación de tablas de dimensiones
--   - Creación de tablas de hechos
--   - Creación de índices y restricciones básicas
-- ==========================================

-- 0) Esquema del Avance 2
CREATE SCHEMA IF NOT EXISTS avance2;

-- Definir search_path para trabajar más cómodo
SET search_path TO avance2, public;


-- ==========================================
-- 1) DIMENSIONES
-- ==========================================

-- 1.1 Dimensión de usuarios / clientes
CREATE TABLE IF NOT EXISTS avance2.d_usuario (
    usuario_key  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id   INTEGER,              -- clave natural (de public.usuarios)
    nombre       VARCHAR(100),
    apellido     VARCHAR(100),
    dni          VARCHAR(20),
    email        VARCHAR(255),
    contrasena   VARCHAR(100)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_d_usuario_usuario_id
    ON avance2.d_usuario (usuario_id);


-- 1.2 Dimensión de categorías de producto
CREATE TABLE IF NOT EXISTS avance2.d_categoria (
    categoria_key          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    categoria_id           INTEGER NOT NULL,        -- clave natural usada en productos
    nombre_categoria       VARCHAR(100) NOT NULL,
    descripcion_categoria  TEXT,
    CONSTRAINT uq_d_categoria_categoria_id UNIQUE (categoria_id)
);


-- 1.3 Dimensión de productos
CREATE TABLE IF NOT EXISTS avance2.d_producto (
    producto_key         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    producto_id          INTEGER NOT NULL,          -- clave natural (ID de producto)
    nombre_producto      VARCHAR(200) NOT NULL,
    descripcion_producto TEXT,
    precio               NUMERIC(12,2),
    stock                INTEGER,
    categoria_key        INTEGER,                   -- FK a d_categoria
    categoria_id         INTEGER,                   -- clave natural de categoría
    CONSTRAINT uq_d_producto_producto_id UNIQUE (producto_id),
    CONSTRAINT fk_d_producto_categoria
        FOREIGN KEY (categoria_key)
        REFERENCES avance2.d_categoria (categoria_key)
);

CREATE INDEX IF NOT EXISTS ix_d_producto_categoria_key
    ON avance2.d_producto (categoria_key);


-- 1.4 Dimensión de tiempo / calendario
CREATE TABLE IF NOT EXISTS avance2.d_tiempo (
    tiempo_key          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    fecha               DATE NOT NULL,
    anio                INTEGER NOT NULL,
    mes                 INTEGER NOT NULL,
    nombre_mes          VARCHAR(20),
    trimestre           INTEGER,
    dia_semana          INTEGER,
    nombre_dia_semana   VARCHAR(20)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_d_tiempo_fecha
    ON avance2.d_tiempo (fecha);


-- 1.5 Dimensión de direcciones de envío / geografía
CREATE TABLE IF NOT EXISTS avance2.d_direccion_envio (
    direccion_key  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_id     INTEGER,
    calle          VARCHAR(200),
    ciudad         VARCHAR(100),
    departamento   VARCHAR(100),
    provincia      VARCHAR(100),
    distrito       VARCHAR(100),
    estado         VARCHAR(100),
    codigo_postal  VARCHAR(20),
    pais           VARCHAR(100)
);

CREATE INDEX IF NOT EXISTS ix_d_direccion_envio_usuario_id
    ON avance2.d_direccion_envio (usuario_id);


-- 1.6 Dimensión de métodos de pago
CREATE TABLE IF NOT EXISTS avance2.d_metodo_pago (
    metodo_pago_key      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    metodo_pago_id       INTEGER NOT NULL,          -- clave natural (ID de método de pago)
    nombre_metodo_pago   VARCHAR(100) NOT NULL,
    descripcion_metodo_pago TEXT,
    CONSTRAINT uq_d_metodo_pago_id UNIQUE (metodo_pago_id)
);


-- 1.7 Dimensión de estados de orden
CREATE TABLE IF NOT EXISTS avance2.d_estado_orden (
    estado_orden_key        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_estado_orden     VARCHAR(50) NOT NULL,   -- p.ej. 'Pendiente', 'Enviado'
    descripcion_estado_orden VARCHAR(255),
    CONSTRAINT uq_d_estado_orden_codigo UNIQUE (codigo_estado_orden)
);


-- 1.8 Dimensión de estados de pago
CREATE TABLE IF NOT EXISTS avance2.d_estado_pago (
    estado_pago_key         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    codigo_estado_pago      VARCHAR(50) NOT NULL,   -- p.ej. 'Procesando', 'Fallido'
    descripcion_estado_pago VARCHAR(255),
    CONSTRAINT uq_d_estado_pago_codigo UNIQUE (codigo_estado_pago)
);


-- ==========================================
-- 2) TABLAS DE HECHOS
-- ==========================================

-- 2.1 Hecho de Órdenes (cabecera)
CREATE TABLE IF NOT EXISTS avance2.f_ordenes (
    orden_key          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    orden_id           INTEGER,                -- identificador de orden (degenerado)
    usuario_key        INTEGER NOT NULL,
    tiempo_key         INTEGER NOT NULL,
    direccion_key      INTEGER,
    estado_orden_key   INTEGER,
    total_orden        NUMERIC(12,2) NOT NULL,
    cantidad_productos INTEGER,                -- total de ítems de la orden

    CONSTRAINT fk_f_ordenes_usuario
        FOREIGN KEY (usuario_key)
        REFERENCES avance2.d_usuario (usuario_key),

    CONSTRAINT fk_f_ordenes_tiempo
        FOREIGN KEY (tiempo_key)
        REFERENCES avance2.d_tiempo (tiempo_key),

    CONSTRAINT fk_f_ordenes_direccion
        FOREIGN KEY (direccion_key)
        REFERENCES avance2.d_direccion_envio (direccion_key),

    CONSTRAINT fk_f_ordenes_estado
        FOREIGN KEY (estado_orden_key)
        REFERENCES avance2.d_estado_orden (estado_orden_key)
);

CREATE UNIQUE INDEX IF NOT EXISTS ux_f_ordenes_orden_id
    ON avance2.f_ordenes (orden_id);

CREATE INDEX IF NOT EXISTS ix_f_ordenes_usuario_key
    ON avance2.f_ordenes (usuario_key);

CREATE INDEX IF NOT EXISTS ix_f_ordenes_tiempo_key
    ON avance2.f_ordenes (tiempo_key);


-- 2.2 Hecho de Detalle de Órdenes (líneas)
CREATE TABLE IF NOT EXISTS avance2.f_detalle_ordenes (
    detalle_orden_key  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    orden_id           INTEGER,                -- mismo identificador lógico que en f_ordenes
    usuario_key        INTEGER,
    producto_key       INTEGER NOT NULL,
    categoria_key      INTEGER,
    tiempo_key         INTEGER NOT NULL,
    estado_orden_key   INTEGER,
    cantidad           INTEGER NOT NULL,
    precio_unitario    NUMERIC(12,2) NOT NULL,
    importe_linea      NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_f_detalle_ordenes_usuario
        FOREIGN KEY (usuario_key)
        REFERENCES avance2.d_usuario (usuario_key),

    CONSTRAINT fk_f_detalle_ordenes_producto
        FOREIGN KEY (producto_key)
        REFERENCES avance2.d_producto (producto_key),

    CONSTRAINT fk_f_detalle_ordenes_categoria
        FOREIGN KEY (categoria_key)
        REFERENCES avance2.d_categoria (categoria_key),

    CONSTRAINT fk_f_detalle_ordenes_tiempo
        FOREIGN KEY (tiempo_key)
        REFERENCES avance2.d_tiempo (tiempo_key),

    CONSTRAINT fk_f_detalle_ordenes_estado
        FOREIGN KEY (estado_orden_key)
        REFERENCES avance2.d_estado_orden (estado_orden_key)
);

CREATE INDEX IF NOT EXISTS ix_f_detalle_ordenes_orden_id
    ON avance2.f_detalle_ordenes (orden_id);

CREATE INDEX IF NOT EXISTS ix_f_detalle_ordenes_producto_key
    ON avance2.f_detalle_ordenes (producto_key);


-- 2.3 Hecho de Pagos
CREATE TABLE IF NOT EXISTS avance2.f_pagos (
    pago_key         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    orden_id         INTEGER,
    usuario_key      INTEGER,
    metodo_pago_key  INTEGER NOT NULL,
    estado_pago_key  INTEGER,
    tiempo_key       INTEGER NOT NULL,
    monto_pago       NUMERIC(12,2) NOT NULL,

    CONSTRAINT fk_f_pagos_usuario
        FOREIGN KEY (usuario_key)
        REFERENCES avance2.d_usuario (usuario_key),

    CONSTRAINT fk_f_pagos_metodo_pago
        FOREIGN KEY (metodo_pago_key)
        REFERENCES avance2.d_metodo_pago (metodo_pago_key),

    CONSTRAINT fk_f_pagos_estado_pago
        FOREIGN KEY (estado_pago_key)
        REFERENCES avance2.d_estado_pago (estado_pago_key),

    CONSTRAINT fk_f_pagos_tiempo
        FOREIGN KEY (tiempo_key)
        REFERENCES avance2.d_tiempo (tiempo_key)
);

CREATE INDEX IF NOT EXISTS ix_f_pagos_orden_id
    ON avance2.f_pagos (orden_id);

CREATE INDEX IF NOT EXISTS ix_f_pagos_metodo_pago_key
    ON avance2.f_pagos (metodo_pago_key);


-- 2.4 Hecho de Reseñas de Productos
CREATE TABLE IF NOT EXISTS avance2.f_resenas_productos (
    resena_key    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_key   INTEGER NOT NULL,
    producto_key  INTEGER NOT NULL,
    categoria_key INTEGER,
    tiempo_key    INTEGER NOT NULL,
    calificacion  INTEGER NOT NULL,

    CONSTRAINT fk_f_resenas_usuario
        FOREIGN KEY (usuario_key)
        REFERENCES avance2.d_usuario (usuario_key),

    CONSTRAINT fk_f_resenas_producto
        FOREIGN KEY (producto_key)
        REFERENCES avance2.d_producto (producto_key),

    CONSTRAINT fk_f_resenas_categoria
        FOREIGN KEY (categoria_key)
        REFERENCES avance2.d_categoria (categoria_key),

    CONSTRAINT fk_f_resenas_tiempo
        FOREIGN KEY (tiempo_key)
        REFERENCES avance2.d_tiempo (tiempo_key),

    CONSTRAINT ck_f_resenas_calificacion
        CHECK (calificacion BETWEEN 1 AND 5)
);

CREATE INDEX IF NOT EXISTS ix_f_resenas_productos_producto_key
    ON avance2.f_resenas_productos (producto_key);

CREATE INDEX IF NOT EXISTS ix_f_resenas_productos_usuario_key
    ON avance2.f_resenas_productos (usuario_key);


-- 2.5 Hecho de Carrito
CREATE TABLE IF NOT EXISTS avance2.f_carrito (
    carrito_key   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    usuario_key   INTEGER NOT NULL,
    producto_key  INTEGER NOT NULL,
    categoria_key INTEGER,
    tiempo_key    INTEGER NOT NULL,
    cantidad      INTEGER NOT NULL,

    CONSTRAINT fk_f_carrito_usuario
        FOREIGN KEY (usuario_key)
        REFERENCES avance2.d_usuario (usuario_key),

    CONSTRAINT fk_f_carrito_producto
        FOREIGN KEY (producto_key)
        REFERENCES avance2.d_producto (producto_key),

    CONSTRAINT fk_f_carrito_categoria
        FOREIGN KEY (categoria_key)
        REFERENCES avance2.d_categoria (categoria_key),

    CONSTRAINT fk_f_carrito_tiempo
        FOREIGN KEY (tiempo_key)
        REFERENCES avance2.d_tiempo (tiempo_key)
);

CREATE INDEX IF NOT EXISTS ix_f_carrito_usuario_key
    ON avance2.f_carrito (usuario_key);

CREATE INDEX IF NOT EXISTS ix_f_carrito_producto_key
    ON avance2.f_carrito (producto_key);

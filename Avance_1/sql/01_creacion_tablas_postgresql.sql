-- ============================
-- TABLAS MAESTRAS / DIMENSIONES
-- ============================

-- Tabla de usuarios
CREATE TABLE usuarios (
    usuario_id      SERIAL PRIMARY KEY,
    nombre          TEXT,
    apellido        TEXT,
    dni             INTEGER,
    email           TEXT,
    contrasena      TEXT
);

-- Tabla de categorías de productos
CREATE TABLE categorias (
    categoria_id    SERIAL PRIMARY KEY,
    nombre          TEXT,
    descripcion     TEXT
);

-- Tabla de productos
CREATE TABLE productos (
    producto_id     SERIAL PRIMARY KEY,
    nombre          TEXT,
    descripcion     TEXT,
    precio          NUMERIC(10,2),
    stock           INTEGER,
    categoria_id    INTEGER REFERENCES categorias(categoria_id)
);

-- Tabla de métodos de pago
CREATE TABLE metodos_pago (
    metodo_pago_id  SERIAL PRIMARY KEY,
    nombre          TEXT,
    descripcion     TEXT
);

-- ============================
-- TABLAS DE HECHOS / RELACIONES
-- ============================

-- Tabla de órdenes/pedidos
CREATE TABLE ordenes (
    orden_id        SERIAL PRIMARY KEY,
    usuario_id      INTEGER REFERENCES usuarios(usuario_id),
    fecha_orden     TIMESTAMP,
    total           NUMERIC(10,2),
    estado          TEXT
);

-- Detalle de cada orden (líneas de productos)
CREATE TABLE detalle_ordenes (
    detalle_id      SERIAL PRIMARY KEY,
    orden_id        INTEGER REFERENCES ordenes(orden_id),
    producto_id     INTEGER REFERENCES productos(producto_id),
    cantidad        INTEGER,
    precio_unitario NUMERIC(10,2)
);

-- Direcciones de envío de los usuarios
CREATE TABLE direcciones_envio (
    direccion_id    SERIAL PRIMARY KEY,
    usuario_id      INTEGER REFERENCES usuarios(usuario_id),
    calle           TEXT,
    ciudad          TEXT,
    departamento    TEXT,
    provincia       TEXT,
    distrito        TEXT,
    estado          TEXT,
    codigo_postal   TEXT,
    pais            TEXT
);

-- Carrito de compras
CREATE TABLE carrito (
    carrito_id      SERIAL PRIMARY KEY,
    usuario_id      INTEGER REFERENCES usuarios(usuario_id),
    producto_id     INTEGER REFERENCES productos(producto_id),
    cantidad        INTEGER,
    fecha_agregado  TIMESTAMP
);

-- Relación orden - método de pago (por si hay varios pagos por orden)
CREATE TABLE ordenes_metodospago (
    orden_metodo_pago_id  SERIAL PRIMARY KEY,
    orden_id              INTEGER REFERENCES ordenes(orden_id),
    metodo_pago_id        INTEGER REFERENCES metodos_pago(metodo_pago_id),
    monto_pagado          NUMERIC(10,2)
);

-- Reseñas de productos
CREATE TABLE resenas_productos (
    resena_id       SERIAL PRIMARY KEY,
    usuario_id      INTEGER REFERENCES usuarios(usuario_id),
    producto_id     INTEGER REFERENCES productos(producto_id),
    calificacion    INTEGER,
    comentario      TEXT,
    fecha           TIMESTAMP
);

-- Historial de pagos
CREATE TABLE historial_pagos (
    historial_pago_id  SERIAL PRIMARY KEY,
    orden_id           INTEGER REFERENCES ordenes(orden_id),
    metodo_pago_id     INTEGER REFERENCES metodos_pago(metodo_pago_id),
    monto              NUMERIC(10,2),
    fecha_pago         TIMESTAMP,
    estado_pago        TEXT
);

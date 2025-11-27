# Avance 3 – Modelado con dbt (staging / interm / marts) sobre EcommerceDB

Este avance toma el diseño lógico del **Avance 2** (esquema en estrella sobre EcommerceDB) y lo implementa en **dbt** usando tres capas:

- `dbt_staging`  → vistas de staging cercanas al origen (`public`)
- `dbt_interm`   → tablas intermedias con lógica de negocio (joins y cálculos)
- `dbt_marts`    → tablas finales de dimensiones y hechos (modelo estrella)

La orquestación de dbt se realiza dentro de un contenedor Docker definido en `docker-compose.yml`.

---

## 1. Prerrequisitos

- **Docker Desktop** instalado y funcionando (engine en estado `running`).
- **PostgreSQL** accesible desde el host con:
  - Base de datos: `EcommerceDB`
  - Usuario: `postgres` (o el que se definió en `profiles.yml`)
  - Host visto desde el contenedor: `host.docker.internal`
- Tablas de origen creadas y pobladas en el esquema `public`:
  - `usuarios`, `categorias`, `productos`, `metodos_pago`
  - `ordenes`, `detalle_ordenes`, `direcciones_envio`, `carrito`
  - `ordenes_metodospago`, `resenas_productos`, `historial_pagos`

---

## 2. Estructura de carpetas del Avance 3

```text
Avance_3/
├─ docker-compose.yml           # Definición del servicio dbt (contenedor)
├─ .env                         # Variables de entorno locales (NO se versiona)
├─ profiles/
│   └─ profiles.yml             # Profile de dbt (conexión a PostgreSQL)
└─ dbt_ecommerce/
    ├─ dbt_project.yml          # Configuración del proyecto dbt
    ├─ models/
    │   ├─ staging/             # Modelos de capa staging (vistas en dbt_staging)
    │   │   ├─ src_ecommerce.yml
    │   │   ├─ stg_usuarios.sql
    │   │   ├─ stg_categorias.sql
    │   │   ├─ stg_productos.sql
    │   │   ├─ stg_ordenes.sql
    │   │   ├─ stg_detalle_ordenes.sql
    │   │   ├─ stg_direcciones_envio.sql
    │   │   ├─ stg_carrito.sql
    │   │   ├─ stg_metodos_pago.sql
    │   │   ├─ stg_ordenes_metodospago.sql
    │   │   ├─ stg_resenas_productos.sql
    │   │   └─ stg_historial_pagos.sql
    │   ├─ interm/              # Modelos intermedios (tablas en dbt_interm)
    │   │   └─ int_detalle_ordenes_enriquecido.sql
    │   └─ marts/               # Dimensiones y hechos (tablas en dbt_marts)
    │       ├─ d_usuario.sql
    │       ├─ d_categoria.sql
    │       ├─ d_producto.sql
    │       ├─ d_direccion_envio.sql
    │       ├─ d_metodo_pago.sql
    │       ├─ d_estado_orden.sql
    │       ├─ d_estado_pago.sql
    │       ├─ d_tiempo.sql
    │       ├─ f_ordenes.sql
    │       ├─ f_detalle_ordenes.sql
    │       ├─ f_pagos.sql
    │       ├─ f_resenas_productos.sql
    │       └─ f_carrito.sql
    └─ target/                  # Artefactos generados por dbt (se puede limpiar)
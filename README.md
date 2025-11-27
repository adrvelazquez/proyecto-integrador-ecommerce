# Proyecto Integrador – Comercio Electrónico (Henry)

Autor: **Adrián Velázquez**  
Base de datos: **EcommerceDB** (PostgreSQL)  

Este repositorio contiene el desarrollo completo del proyecto integrador de un escenario de comercio electrónico, dividido en cuatro avances:

1. **Avance 1:** creación de la base de datos en PostgreSQL, carga de datos desde CSV y análisis exploratorio inicial (SQL + Python/ORM). :contentReference[oaicite:0]{index=0}  
2. **Avance 2:** diseño del modelo dimensional (hechos y dimensiones) y documentación del modelo conceptual, lógico y físico. :contentReference[oaicite:1]{index=1}  
3. **Avance 3:** implementación del modelo con **dbt** sobre PostgreSQL, organizado en capas (staging, interm, marts) y orquestado con Docker Compose. :contentReference[oaicite:2]{index=2}  
4. **Avance 4:** documentación navegable del modelo con **DBT Docs** y desarrollo de un dashboard de **Streamlit** para storytelling y visualización de insights de negocio. :contentReference[oaicite:3]{index=3}  

---

## Arquitectura general

La solución sigue una lógica de capas:

- **Capa raw (public):** tablas originales cargadas desde 11 archivos CSV (usuarios, productos, categorías, órdenes, pagos, reseñas, etc.). :contentReference[oaicite:4]{index=4}  
- **Capa analítica en PostgreSQL (esquema `avance2`):** implementación física del modelo en estrella definido en el Avance 2 (dimensiones D_* y hechos F_*). :contentReference[oaicite:5]{index=5}  
- **Capa dbt (esquemas `dbt_staging`, `dbt_interm`, `dbt_marts`):** modelos SQL gestionados por dbt, con materializaciones, tests y lineage. :contentReference[oaicite:6]{index=6}  
- **Capa de presentación:** 
  - DBT Docs (documentación navegable + lineage).
  - App de Streamlit conectada a EcommerceDB para responder preguntas de negocio sobre ventas, productos, clientes y métodos de pago. :contentReference[oaicite:7]{index=7}  

---

## Estructura del repositorio

_Ejemplo de estructura (puede variar ligeramente según la versión final):_

```text
proyecto_integrador_ecommerce/
├── Avance_1/
│   ├── data_raw/                # CSV originales
│   ├── sql/                     # Scripts DDL y carga (01_creacion_tablas_postgresql.sql, 02_carga_datos_postgresql.sql, etc.)
│   ├── python/
│   │   ├── notebooks/           # Notebooks de EDA con SQLAlchemy y pandas
│   │   └── requirements.txt
│   └── docs/                    # Informe Avance 1 (Word/PDF)
│
├── Avance_2/
│   ├── sql/                     # Scripts DDL/DML del esquema avance2
│   └── docs/                    # Informe de modelado + diagramas (conceptual/lógico/físico)
│
├── Avance_3/
│   ├── docker-compose.yml       # Servicio dbt (imagen dbt-postgres)
│   ├── .env.example             # Ejemplo de variables (sin credenciales reales)
│   ├── profiles/                # profiles.yml para dbt
│   ├── dbt_ecommerce/
│   │   ├── dbt_project.yml
│   │   └── models/
│   │       ├── staging/         # stg_...
│   │       ├── interm/          # int_...
│   │       └── marts/           # d_... y f_...
│   ├── sql/                     # Consultas de validación del modelo
│   └── docs/                    # Informe Avance 3 + capturas de DBT Docs (opcional)
│
├── Avance_4/
│   ├── streamlit_app/
│   │   └── app.py               # App de Streamlit conectada a EcommerceDB
│   └── docs/                    # Informe Avance 4 + capturas de DBT Docs y Streamlit
│
├── README.md
├── .gitignore
└── (opcional) .env              # Variables de entorno locales (NO versionar)

## Requisitos previos

- Git y cuenta en GitHub.
- Docker Desktop (Windows / Mac) y soporte para Docker Compose.
- PostgreSQL (si se desea ejecutar fuera de Docker, opcional).
- Python 3.12 + entorno virtual (`.venv`).
- DBeaver o cliente SQL equivalente para revisar la base **EcommerceDB**.
- VS Code como editor principal.

---

## Cómo reproducir el entorno

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu_usuario/proyecto-integrador-ecommerce.git
cd proyecto-integrador_ecommerce

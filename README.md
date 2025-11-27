# Proyecto Integrador – Comercio Electrónico (Henry)

Autor: **Adrián Velázquez**  
Base de datos: **EcommerceDB** (PostgreSQL)  

Este repositorio contiene el desarrollo completo del proyecto integrador de un escenario de comercio electrónico, dividido en cuatro avances:

1. **Avance 1:** creación de la base de datos en PostgreSQL, carga de datos desde CSV y análisis exploratorio inicial (SQL + Python/ORM). 
2. **Avance 2:** diseño del modelo dimensional (hechos y dimensiones) y documentación del modelo conceptual, lógico y físico.  
3. **Avance 3:** implementación del modelo con **dbt** sobre PostgreSQL, organizado en capas (staging, interm, marts) y orquestado con Docker Compose.  
4. **Avance 4:** documentación navegable del modelo con **DBT Docs** y desarrollo de un dashboard de **Streamlit** para storytelling y visualización de insights de negocio.

---

## Arquitectura general

La solución sigue una lógica de capas:

- **Capa raw (public):** tablas originales cargadas desde 11 archivos CSV (usuarios, productos, categorías, órdenes, pagos, reseñas, etc.) 
- **Capa analítica en PostgreSQL (esquema `avance2`):** implementación física del modelo en estrella definido en el Avance 2 (dimensiones D_* y hechos F_*).
- **Capa dbt (esquemas `dbt_staging`, `dbt_interm`, `dbt_marts`):** modelos SQL gestionados por dbt, con materializaciones, tests y lineage.
- **Capa de presentación:** 
  - DBT Docs (documentación navegable + lineage).
  - App de Streamlit conectada a EcommerceDB para responder preguntas de negocio sobre ventas, productos, clientes y métodos de pago.

---

## Estructura del repositorio

_Ejemplo de estructura:_

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
2. Configurar entorno de Python
bash
Copiar código
python -m venv .venv
.\.venv\Scripts\activate    # Windows
pip install --upgrade pip
pip install -r Avance_1/python/requirements.txt
Si no se usa el requirements.txt original, instalar al menos:
sqlalchemy, psycopg2-binary, pandas, matplotlib, python-dotenv, streamlit.

Crear un archivo .env (no se versiona) con las credenciales de PostgreSQL, por ejemplo:

env
Copiar código
PG_ECOMMERCE_HOST=localhost
PG_ECOMMERCE_PORT=5432
PG_ECOMMERCE_DB=EcommerceDB
PG_ECOMMERCE_USER=postgres
PG_ECOMMERCE_PWD=tu_password
3. Levantar la base de datos y dbt con Docker
Desde la carpeta Avance_3:

bash
Copiar código
cd Avance_3
docker compose up -d
docker compose ps
Esto levanta:

Contenedor de PostgreSQL con la base EcommerceDB.

Contenedor de dbt configurado para conectarse a esa base.

Las tablas originales (raw) deben estar previamente cargadas en el esquema public (scripts del Avance 1).

4. Ejecutar modelos de dbt
Con los contenedores arriba, desde Avance_3:

bash
Copiar código
# Staging + interm + marts
docker compose exec dbt dbt run

# Tests de calidad
docker compose exec dbt dbt test

# Documentación de dbt
docker compose exec dbt dbt docs generate
docker compose exec dbt dbt docs serve --port 8080 --host 0.0.0.0 --no-browser
Luego abrir en el navegador:

text
Copiar código
http://localhost:8080
para navegar DBT Docs (modelos, columnas, lineage, etc.).

5. Ejecutar la app de Streamlit
Desde la raíz del proyecto, con el entorno .venv activo:

bash
Copiar código
cd Avance_4/streamlit_app
streamlit run app.py
La app se abre en:

text
Copiar código
http://localhost:8501
Desde allí se puede:

Probar la conexión a EcommerceDB.

Ver la evolución de ventas mensuales.

Analizar ventas por categoría.

Ver el top de productos y clientes.

Analizar métodos de pago más utilizados.

Documentación de los avances
En la carpeta Avance_X/docs/ se incluyen los informes en Word/PDF que documentan cada etapa:

Avance 1 – Modelado inicial, carga y EDA.

Avance 2 – Modelado dimensional (hechos y dimensiones).

Avance 3 – Implementación con dbt y validaciones.

Avance 4 – DBT Docs y storytelling con Streamlit.

Estos documentos describen detalladamente decisiones de diseño, obstáculos encontrados, validaciones realizadas y conclusiones de cada avance.

Notas finales
Este proyecto integra buenas prácticas de Ingeniería de Datos:

Separación por capas (raw, modelo dimensional, dbt, presentación).

Uso de Docker y dbt para obtener pipelines reproducibles.

Gestión de credenciales mediante .env y .gitignore.

Validaciones de calidad y documentación automatizada (DBT Docs).

Storytelling de negocio con una app ligera de Streamlit.

Cualquier sugerencia o mejora futura (nuevas métricas, más tests de calidad, integración con herramientas BI) es bienvenida.
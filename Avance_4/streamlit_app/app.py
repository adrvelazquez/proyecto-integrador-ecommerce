import streamlit as st
import pandas as pd
from sqlalchemy import create_engine, text

# ----------------------------------------------------
# Configuración de la página
# ----------------------------------------------------
st.set_page_config(
    page_title="Ecommerce – Avance 4",
    layout="wide"
)

st.title("Ecommerce – Análisis de ventas (Avance 4)")
st.markdown(
    """
    Dashboard construido con **Streamlit** conectado a **PostgreSQL (EcommerceDB)**.

    Los datos provienen del modelo dimensional (tablas de hechos y dimensiones)
    que diseñaste en los avances anteriores.
    """
)

# ----------------------------------------------------
# Parámetros de conexión a la base
# ----------------------------------------------------
DB_USER = "postgres"       
DB_PASSWORD = 27503861     
DB_HOST = "localhost"
DB_PORT = "5432"           
DB_NAME = "EcommerceDB"    

# Esquema donde están las tablas dimensionales/facts

DEFAULT_SCHEMA = "avance2"

# ----------------------------------------------------
# Sidebar – Parámetros
# ----------------------------------------------------
st.sidebar.header("Parámetros")

schema_marts = st.sidebar.text_input(
    "Esquema de las tablas dimensionales/facts",
    value=DEFAULT_SCHEMA,
    help="Ej: avance2, dbt_marts, public..."
)

st.sidebar.markdown("---")
st.sidebar.write("Usa el mismo usuario, contraseña y puerto que en DBeaver.")

# ----------------------------------------------------
# Funciones auxiliares
# ----------------------------------------------------
@st.cache_resource
def get_engine():
    connection_string = (
        f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}"
        f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )
    engine = create_engine(connection_string)
    return engine

def run_query(sql: str) -> pd.DataFrame:
    engine = get_engine()
    with engine.connect() as conn:
        return pd.read_sql(text(sql), conn)

# ----------------------------------------------------
# Bloque 0 – Test de conexión y listado de tablas
# ----------------------------------------------------
st.subheader("0. Conexión y tablas disponibles")

try:
    df_tablas = run_query("""
        SELECT table_schema, table_name
        FROM information_schema.tables
        WHERE table_catalog = 'EcommerceDB'
          AND table_type = 'BASE TABLE'
        ORDER BY table_schema, table_name
        LIMIT 50;
    """)
    st.dataframe(df_tablas)
    st.caption("Primeras 50 tablas encontradas en EcommerceDB.")
except Exception as e:
    st.error(f"No se pudo listar las tablas. Revisa la conexión. Detalle: {e}")

st.markdown("---")

# ----------------------------------------------------
# 1) Ventas mensuales (cantidad y monto)
# ----------------------------------------------------
st.subheader("1. Evolución de ventas mensuales")

sql_ventas_mes = f"""
SELECT
    t.anio,              -- ajusta según tu d_tiempo (por ejemplo 'anio' o 'year')
    t.mes,               -- ajusta si tu columna es 'mes' o 'month'
    CONCAT(t.anio, '-', LPAD(t.mes::text, 2, '0')) AS anio_mes,
    SUM(fd.importe_linea) AS ventas_totales,     -- ajusta al nombre de tu campo de monto
    SUM(fd.cantidad) AS unidades_totales         -- ajusta si la columna se llama distinto
FROM {schema_marts}.f_detalle_ordenes fd
JOIN {schema_marts}.d_tiempo t
  ON fd.tiempo_key = t.tiempo_key
GROUP BY t.anio, t.mes
ORDER BY t.anio, t.mes;
"""

try:
    df_ventas_mes = run_query(sql_ventas_mes)
    if not df_ventas_mes.empty:
        df_ventas_mes["anio_mes"] = df_ventas_mes["anio_mes"].astype(str)
        st.bar_chart(df_ventas_mes.set_index("anio_mes")[["ventas_totales"]])
        st.caption("Ventas totales (importe_linea) por mes.")
        st.dataframe(df_ventas_mes)
    else:
        st.info("La consulta de ventas mensuales no devolvió datos. Revisa nombres de tablas/columnas.")
except Exception as e:
    st.error(f"No se pudo ejecutar la consulta de ventas mensuales. Revisa nombres de tablas/columnas. Detalle: {e}")

st.markdown("---")

# ----------------------------------------------------
# 2) Ventas por categoría
# ----------------------------------------------------
st.subheader("2. Ventas por categoría")

sql_ventas_categoria = f"""
SELECT
    c.nombre_categoria AS categoria,  -- ajusta al nombre real de la columna en d_categoria
    SUM(fd.importe_linea) AS ventas_totales
FROM {schema_marts}.f_detalle_ordenes fd
JOIN {schema_marts}.d_producto p
  ON fd.producto_key = p.producto_key
JOIN {schema_marts}.d_categoria c
  ON p.categoria_key = c.categoria_key
GROUP BY c.nombre_categoria
ORDER BY ventas_totales DESC;
"""

try:
    df_cat = run_query(sql_ventas_categoria)
    if not df_cat.empty:
        st.bar_chart(df_cat.set_index("categoria")["ventas_totales"])
        st.dataframe(df_cat)
        st.caption("Ventas totales por categoría de producto.")
    else:
        st.info("La consulta de ventas por categoría no devolvió datos. Revisa nombres de tablas/columnas.")
except Exception as e:
    st.error(f"No se pudo ejecutar la consulta de ventas por categoría. Detalle: {e}")

st.markdown("---")

# ----------------------------------------------------
# 3) Top 10 productos por ventas
# ----------------------------------------------------
st.subheader("3. Top 10 productos por ventas")

sql_top_productos = f"""
SELECT
    p.nombre_producto AS producto,    -- ajusta al nombre real (ej: 'nombre')
    SUM(fd.cantidad) AS unidades_vendidas,
    SUM(fd.importe_linea) AS ventas_totales
FROM {schema_marts}.f_detalle_ordenes fd
JOIN {schema_marts}.d_producto p
  ON fd.producto_key = p.producto_key
GROUP BY p.nombre_producto
ORDER BY ventas_totales DESC
LIMIT 10;
"""

try:
    df_top_prod = run_query(sql_top_productos)

    col1, col2 = st.columns(2)

    with col1:
        if not df_top_prod.empty:
            st.bar_chart(df_top_prod.set_index("producto")["ventas_totales"])
            st.caption("Top 10 productos por monto de ventas.")
        else:
            st.info("La consulta de top productos no devolvió datos.")

    with col2:
        if not df_top_prod.empty:
            st.dataframe(df_top_prod)
        else:
            st.empty()
except Exception as e:
    st.error(f"No se pudo ejecutar la consulta de top productos. Detalle: {e}")

st.markdown("---")

# ----------------------------------------------------
# 4) Métodos de pago más utilizados (si existe f_pagos)
# ----------------------------------------------------
st.subheader("4. Métodos de pago más utilizados")

sql_metodos_pago = f"""
SELECT
    mp.nombre_metodo_pago AS metodo_pago,   -- ajusta al nombre real
    COUNT(*) AS cantidad_pagos,
    SUM(fp.monto_pago) AS monto_total       -- ajusta al nombre de la columna de monto
FROM {schema_marts}.f_pagos fp
JOIN {schema_marts}.d_metodo_pago mp
  ON fp.metodo_pago_key = mp.metodo_pago_key
GROUP BY mp.nombre_metodo_pago
ORDER BY monto_total DESC;
"""

try:
    df_pago = run_query(sql_metodos_pago)
    if not df_pago.empty:
        st.bar_chart(df_pago.set_index("metodo_pago")["monto_total"])
        st.dataframe(df_pago)
        st.caption("Monto total pagado por método de pago.")
    else:
        st.info("La consulta de métodos de pago no devolvió datos. Si no tenés f_pagos/d_metodo_pago, podés omitir esta sección.")
except Exception as e:
    st.info("No se pudo ejecutar la consulta de métodos de pago. "
            "Si no tenés f_pagos/d_metodo_pago, podés ignorar esta sección.")
    st.caption(f"Detalle técnico: {e}")

st.markdown("---")

# ----------------------------------------------------
# 5) Top 10 clientes por monto total
# ----------------------------------------------------
st.subheader("5. Top 10 clientes por monto total")

sql_top_clientes = f"""
SELECT
    (u.nombre || ' ' || u.apellido) AS cliente,  -- ajusta al nombre real de las columnas
    SUM(fd.importe_linea) AS monto_total
FROM {schema_marts}.f_detalle_ordenes fd
JOIN {schema_marts}.d_usuario u
  ON fd.usuario_key = u.usuario_key
GROUP BY cliente
ORDER BY monto_total DESC
LIMIT 10;
"""

try:
    df_clientes = run_query(sql_top_clientes)
    if not df_clientes.empty:
        st.bar_chart(df_clientes.set_index("cliente")["monto_total"])
        st.dataframe(df_clientes)
        st.caption("Clientes con mayor gasto total.")
    else:
        st.info("La consulta de top clientes no devolvió datos. Revisa nombres de tablas/columnas.")
except Exception as e:
    st.error(f"No se pudo ejecutar la consulta de top clientes. Detalle: {e}")

  
    

  create  table "EcommerceDB"."dbt_marts"."d_tiempo__dbt_tmp"
  
  
    as
  
  (
    with fechas as (

    select
        generate_series(
            date '2020-01-01',
            date '2025-12-31',
            interval '1 day'
        )::date as fecha

),

dim as (

    select
        fecha,
        extract(year from fecha)::int    as anio,
        extract(month from fecha)::int   as mes,
        to_char(fecha, 'TMMonth')        as nombre_mes,
        extract(quarter from fecha)::int as trimestre,
        extract(dow from fecha)::int     as dia_semana,
        to_char(fecha, 'TMDay')          as nombre_dia_semana
    from fechas

),

con_clave as (

    select
        row_number() over (order by fecha) as tiempo_key,
        fecha,
        anio,
        mes,
        nombre_mes,
        trimestre,
        dia_semana,
        nombre_dia_semana
    from dim

)

select
    tiempo_key,
    fecha,
    anio,
    mes,
    nombre_mes,
    trimestre,
    dia_semana,
    nombre_dia_semana
from con_clave
  );
  
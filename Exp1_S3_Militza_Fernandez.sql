PROMPT =========================================
PROMPT CASO 1 – LISTADO DE CLIENTES CON RANGO DE RENTA
PROMPT =========================================

-- Muestra clientes según rango de renta ingresado por variables.
-- Aplica formato de RUT, nombre y dirección.
-- Formatea celular en patrón XX-XXX-XXXX con REGEXP_REPLACE.
-- Clasifica por tramo de renta y ordena por nombre ascendente.


SELECT
    LPAD(TO_CHAR(c.numrut_cli, '99G999G999') || '-' || c.dvrut_cli, 15, ' ') AS "RUT Cliente",
    INITCAP(c.nombre_cli || ' ' || c.appaterno_cli || ' ' || c.apmaterno_cli) AS "Nombre Completo Cliente",
    INITCAP(c.direccion_cli) AS "Dirección Cliente",
    TO_CHAR(c.renta_cli, '$9G999G999') AS "Renta Cliente",
    NVL2(
      c.celular_cli,
      REGEXP_REPLACE(
        TO_CHAR(c.celular_cli, 'FM000000000'),
        '(\d{2})(\d{3})(\d{4})',
        '\1-\2-\3'
      ),
      'Sin celular'
    ) AS "Celular Cliente",

    CASE
        WHEN c.renta_cli > 500000 THEN 'TRAMO 1'
        WHEN c.renta_cli BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
        WHEN c.renta_cli BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
        ELSE 'TRAMO 4'
    END AS "Tramo Renta Cliente"
FROM cliente c
WHERE c.renta_cli BETWEEN &RENTA_MINIMA AND &RENTA_MAXIMA
  AND c.celular_cli IS NOT NULL
ORDER BY "Nombre Completo Cliente" ASC;



PROMPT =========================================
PROMPT CASO 2 – SUELDO PROMEDIO POR CATEGORÍA Y SUCURSAL
PROMPT =========================================

-- Calcula promedio de sueldos por categoría y sucursal.
-- Filtra por sueldo promedio mínimo ingresado por variable.
-- Formatea los valores monetarios con separador de miles.
-- Ordena de mayor a menor promedio de sueldo.

SELECT
    ce.id_categoria_emp AS "CÓDIGO_CATEGORIA",
    ce.desc_categoria_emp AS "DESCRIPCIÓN_CATEGORIA",
    COUNT(e.numrut_emp) AS "CANTIDAD_EMPLEADOS",
    s.desc_sucursal AS "SUCURSAL",
    LPAD(TO_CHAR(AVG(e.sueldo_emp), '$9G999G999'), 15, ' ') AS "SUELDO_PROMEDIO"
FROM empleado e
JOIN categoria_empleado ce ON e.id_categoria_emp = ce.id_categoria_emp
JOIN sucursal s ON e.id_sucursal = s.id_sucursal
GROUP BY ce.id_categoria_emp, ce.desc_categoria_emp, s.desc_sucursal
HAVING AVG(e.sueldo_emp) > &SUELDO_PROMEDIO_MINIMO
ORDER BY AVG(e.sueldo_emp) DESC;



PROMPT =========================================
PROMPT CASO 3 – ARRIENDO PROMEDIO POR TIPO DE PROPIEDAD
PROMPT =========================================

-- Agrupa por tipo de propiedad.
-- Calcula promedios de arriendo, superficie y valor por m².
-- Clasifica el arriendo por m² en Económico, Medio o Alto.
-- Muestra solo promedios con valor superior a 1.000.
-- Ordena de mayor a menor valor promedio por m².

SELECT
    LPAD(tp.id_tipo_propiedad,15,' ') AS CODIGO_TIPO,
    UPPER(tp.desc_tipo_propiedad) AS DESCRIPCION_TIPO,
    COUNT(p.nro_propiedad) AS TOTAL_PROPIEDADES,
    LPAD(TO_CHAR(AVG(p.valor_arriendo), '$9G999G999'),15,' ') AS PROMEDIO_ARRIENDO,
    LPAD(TO_CHAR(AVG(p.superficie), '9G999D99'),15,' ') AS PROMEDIO_SUPERFICIE,
    LPAD(TO_CHAR(AVG(p.valor_arriendo / p.superficie), '$99G999'),15,' ') AS VALOR_ARRIENDO_M2,
    CASE
        WHEN AVG(p.valor_arriendo / p.superficie) < 5000 THEN 'Económico'
        WHEN AVG(p.valor_arriendo / p.superficie) BETWEEN 5000 AND 10000 THEN 'Medio'
        ELSE 'Alto'
    END AS CLASIFICACION
FROM propiedad p
JOIN tipo_propiedad tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad
GROUP BY tp.id_tipo_propiedad, tp.desc_tipo_propiedad
HAVING AVG(p.valor_arriendo / p.superficie) > 1000
ORDER BY AVG(p.valor_arriendo / p.superficie) DESC;

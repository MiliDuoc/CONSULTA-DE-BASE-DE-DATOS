PROMPT =========================================
PROMPT CASO 1 - ANALISIS DE FACTURAS (anio anterior)
PROMPT =========================================

SELECT
    f.numfactura AS "N° Factura",
    TO_CHAR(f.fecha, 'DD "de" Month YYYY', 'NLS_DATE_LANGUAGE=SPANISH') AS "Fecha Emisión",
    LPAD(f.rutcliente, 10, '0') AS "RUT Cliente",
    TO_CHAR(ROUND(f.neto, 0) , '$999,999') AS "Monto Neto",
    TO_CHAR(ROUND(f.iva, 0)  , '$999,999') AS "Monto Iva",
    TO_CHAR(ROUND(f.total, 0), '$999,999') AS "Total Factura",
    CASE
        WHEN f.total <= 50000 THEN 'Bajo'
        WHEN f.total BETWEEN 50001 AND 100000 THEN 'Medio'
        ELSE 'Alto'
    END      AS "Categoría Monto",
    DECODE(NVL(f.codpago, 0),
           1, 'EFECTIVO',
           2, 'TARJETA DEBITO',
           3, 'TARJETA CREDITO',
           'CHEQUE')  AS "Forma de pago"
FROM factura f
WHERE EXTRACT(YEAR FROM f.fecha) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY f.numfactura DESC, f.fecha DESC, f.neto DESC;


PROMPT =========================================
PROMPT CASO 2 - CLASIFICACION DE CLIENTES
PROMPT =========================================

SELECT
    LPAD((c.rutcliente),12,'*') AS "RUT",
    INITCAP(c.nombre) AS "Cliente",
    NVL(TO_CHAR(c.telefono),'Sin teléfono') AS "TELÉFONO",
    NVL(TO_CHAR(c.codcomuna),'Sin comuna') AS "COMUNA",
    c.estado AS "ESTADO",
    CASE 
        WHEN (c.saldo / c.credito) < 0.5 THEN 
            'Bueno ( ' || TO_CHAR((c.credito - c.saldo),'$9G999G999') || ' )'
        WHEN (c.saldo / c.credito) BETWEEN 0.5 AND 0.8 THEN 
            'Regular ( ' || TO_CHAR(c.saldo,'$9G999G999') || ' )'
        ELSE 
            'Crítico'
    END AS "Estado Crédito",
    NVL(UPPER(SUBSTR(c.mail, INSTR(c.mail,'@')+1)), 'Correo no registrado') AS "Dominio Correo"
FROM cliente c
WHERE c.estado = 'A'
  AND c.credito > 0
ORDER BY c.nombre ASC;


PROMPT =========================================
PROMPT CASO 3 - STOCK DE PRODUCTOS
PROMPT =========================================


SELECT
    p.codproducto AS "ID",
    INITCAP(p.descripcion) AS "Descripción de Producto",
    CASE 
        WHEN p.valorcompradolar IS NULL THEN 'Sin registro'
        ELSE TO_CHAR(p.valorcompradolar, '990.99') || ' USD'
    END AS "Compra en USD",
    CASE 
        WHEN p.valorcompradolar IS NULL THEN 'Sin registro'
        ELSE TO_CHAR(ROUND(p.valorcompradolar * &TIPOCAMBIO_DOLAR, 0), '$999,999') || ' PESOS'
    END AS "USD convertido",
    p.totalstock AS "Stock",
    CASE
        WHEN p.totalstock IS NULL THEN 'SIN DATOS'
        WHEN p.totalstock < &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
        WHEN p.totalstock BETWEEN &UMBRAL_BAJO AND &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
        ELSE 'OK'
    END AS "Alerta Stock",
    CASE
        WHEN p.totalstock > 80 THEN 
            TO_CHAR(ROUND(p.vunitario * 0.9), '$99,999')
        ELSE 'N/A'
    END AS "Precio Oferta"
FROM producto p
WHERE LOWER(p.descripcion) LIKE '%zapato%'
  AND UPPER(p.procedencia) = 'I'
ORDER BY p.codproducto DESC;

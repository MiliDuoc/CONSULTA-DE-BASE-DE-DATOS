-----------------------------------------
-- CASO 1 – LISTADO DE TRABAJADORES
-----------------------------------------
SELECT
    T.NOMBRE || ' ' || T.APPATERNO|| ' '|| T.APMATERNO AS "Nombre Completo Trabajador",
    TO_CHAR(T.NUMRUT, '99G999G999')|| '-'|| T.DVRUT AS "RUT Trabajador",
    TT.DESC_CATEGORIA                    AS "Tipo Trabajador",
    UPPER(C.NOMBRE_CIUDAD)               AS "Ciudad Trabajador",
    LPAD(TO_CHAR(t.SUELDO_BASE, '$9G999G999'), 15, ' ')  AS "Sueldo Base"
FROM
         TRABAJADOR T
    JOIN TIPO_TRABAJADOR TT ON T.ID_CATEGORIA_T = TT.ID_CATEGORIA
    JOIN COMUNA_CIUDAD   C ON T.ID_CIUDAD = C.ID_CIUDAD
WHERE
    NVL(T.SUELDO_BASE, 0) BETWEEN 650000 AND 3000000
ORDER BY
    C.NOMBRE_CIUDAD DESC,
    T.SUELDO_BASE ASC;      

-----------------------------------------
-- CASO 2 – LISTADO DE CAJEROS
-----------------------------------------

SELECT
    TO_CHAR(t.numrut, '99G999G999') || '-' || t.dvrut AS "RUT Trabajador",
    INITCAP(t.nombre) || ' ' || UPPER(t.appaterno) AS "Nombre Trabajador",
    COUNT(tc.nro_ticket) AS "Total Tickets",
    LPAD(TO_CHAR(SUM(tc.monto_ticket), '$9G999G999'), 15, ' ') AS "Total Vendido",
    LPAD(TO_CHAR(SUM(NVL(ct.valor_comision,0)), '$9G999G999'), 15, ' ') AS "Comisión Total",
    UPPER(tt.desc_categoria) AS "Tipo Trabajador",
    UPPER(c.nombre_ciudad) AS "Ciudad Trabajador"
FROM   trabajador t
    JOIN tipo_trabajador tt  ON t.id_categoria_t = tt.id_categoria
    JOIN comuna_ciudad c     ON t.id_ciudad      = c.id_ciudad
    JOIN tickets_concierto tc ON tc.numrut_t     = t.numrut
    LEFT JOIN comisiones_ticket ct ON ct.nro_ticket = tc.nro_ticket
WHERE  UPPER(tt.desc_categoria) = 'CAJERO'
GROUP BY
    t.numrut, t.dvrut,
    t.nombre, t.appaterno,
    tt.desc_categoria,
    c.nombre_ciudad
HAVING SUM(tc.monto_ticket) > 50000
ORDER BY 
    SUM(tc.monto_ticket) DESC;


-----------------------------------------
-- CASO 3 – LISTADO DE BONIFICACIONES
-----------------------------------------

SELECT
       TO_CHAR(t.numrut, '99G999G999') || '-' || t.dvrut AS "RUT Trabajador",
       INITCAP(t.nombre || ' ' || t.appaterno) AS "Trabajador Nombre",
       EXTRACT(YEAR FROM t.fecing)  AS "Año Ingreso",
       EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.fecing) AS "Años Antigüedad",
       COUNT(af.numrut_carga)  AS "Num. Cargas Familiares",
       LPAD(INITCAP(i.nombre_isapre) , 15, ' ')  AS "Nombre Isapre",
       LPAD(TO_CHAR(t.sueldo_base, '$9G999G999'), 15, ' ') AS "Sueldo Base",
       LPAD(
            TO_CHAR(
                CASE WHEN UPPER(i.nombre_isapre) = 'FONASA' 
                     THEN t.sueldo_base * 0.01 
                     ELSE 0 
                END, 
            '$9G999G999'), 15, ' ')  AS "Bono Fonasa",
       LPAD(
            TO_CHAR(
                CASE 
                    WHEN (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.fecing)) <= 10
                        THEN t.sueldo_base * 0.10
                    ELSE
                        t.sueldo_base * 0.15
                END, 
            '$9G999G999'), 15, ' ')   AS "Bono Antigüedad",
       INITCAP(a.nombre_afp) AS "Nombre AFP",
       UPPER(ec.desc_estcivil)  AS "Estado Civil"
FROM   trabajador t
       JOIN isapre i ON t.cod_isapre= i.cod_isapre
       JOIN afp a ON t.cod_afp = a.cod_afp
       LEFT JOIN asignacion_familiar af ON af.numrut_t = t.numrut
       JOIN est_civil e  ON e.numrut_t = t.numrut
       JOIN estado_civil ec ON ec.id_estcivil = e.id_estcivil_est
WHERE  e.fecter_estcivil IS NULL
        OR e.fecter_estcivil > SYSDATE
GROUP BY
       t.numrut, t.dvrut,
       t.nombre, t.appaterno, t.apmaterno,
       t.fecing, t.sueldo_base,
       i.nombre_isapre,
       a.nombre_afp,
       ec.desc_estcivil
ORDER BY
       t.numrut ASC;

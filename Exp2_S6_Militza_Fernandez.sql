--CASO 1 

SELECT
    id_profesional AS ID,
    profesional,
    SUM(nro_banca) AS nro_asesoria_banca,
    TO_CHAR(SUM(monto_banca), '$9G999G999G999') AS monto_total_banca,
    SUM(nro_retail) AS nro_asesoria_retail,
    TO_CHAR(SUM(monto_retail), '$9G999G999G999') AS monto_total_retail,
    SUM(nro_banca + nro_retail) AS total_asesorias,
    TO_CHAR(SUM(monto_banca + monto_retail), '$9G999G999G999') AS total_honorarios
FROM (

        SELECT
            p.id_profesional,
            INITCAP(p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre) AS profesional,
            COUNT(a.honorario) AS nro_banca,
            NVL(SUM(a.honorario),0) AS monto_banca,
            0 AS nro_retail,
            0 AS monto_retail
        FROM profesional p
        JOIN asesoria a ON p.id_profesional = a.id_profesional
        JOIN empresa e  ON a.cod_empresa = e.cod_empresa
        WHERE e.cod_sector = 3
        GROUP BY p.id_profesional, p.appaterno, p.apmaterno, p.nombre

        UNION ALL

        SELECT
            p.id_profesional,
            INITCAP(p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre) AS profesional,
            0 AS nro_banca,
            0 AS monto_banca,
            COUNT(a.honorario) AS nro_retail,
            NVL(SUM(a.honorario),0) AS monto_retail
        FROM profesional p
        JOIN asesoria a ON p.id_profesional = a.id_profesional
        JOIN empresa e  ON a.cod_empresa    = e.cod_empresa
        WHERE e.cod_sector = 4
        GROUP BY p.id_profesional, p.appaterno, p.apmaterno, p.nombre
)
GROUP BY id_profesional, profesional
HAVING SUM(nro_banca) > 0 AND SUM(nro_retail) > 0
ORDER BY id_profesional;


--CASO 2 pt1

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE REPORTE_MES PURGE';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
 
CREATE TABLE REPORTE_MES AS
SELECT
    p.id_profesional AS id_profesional,
    INITCAP(p.appaterno || ' ' || p.apmaterno || ' ' || p.nombre)  AS nombre_completo,
    pr.nombre_profesion AS nombre_profesion,
    c.nom_comuna  AS nom_comuna,
    COUNT(a.honorario) AS nro_asesorias,
    ROUND(SUM(a.honorario)) AS monto_total_honorarios,
    ROUND(AVG(a.honorario)) AS promedio_honorarios,
    MIN(a.honorario) AS honorario_minimo,
    MAX(a.honorario) AS honorario_maximo
FROM profesional p
JOIN asesoria a ON p.id_profesional = a.id_profesional
JOIN profesion pr ON p.cod_profesion = pr.cod_profesion
JOIN comuna c ON p.cod_comuna = c.cod_comuna
WHERE EXTRACT(MONTH FROM a.fin_asesoria) = 4
  AND EXTRACT(YEAR FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
GROUP BY 
    p.id_profesional,
    p.appaterno, p.apmaterno, p.nombre,
    pr.nombre_profesion,
    c.nom_comuna
ORDER BY 
    p.id_profesional;


--CASO 2 pt2

SELECT
    id_profesional,
    nombre_completo,
    nombre_profesion,
    nom_comuna,
    nro_asesorias,
    monto_total_honorarios,
    promedio_honorarios,
    honorario_minimo,
    honorario_maximo
FROM REPORTE_MES
ORDER BY id_profesional;

--CASO 3 pt1

SELECT
    NVL((
        SELECT SUM(a.honorario)
        FROM asesoria a
        WHERE a.id_profesional = p.id_profesional
          AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
          AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
    ),0) AS honorario,
    p.id_profesional,
    p.numrun_prof,
    p.sueldo
FROM profesional p
WHERE (
        SELECT SUM(a.honorario)
        FROM asesoria a
        WHERE a.id_profesional = p.id_profesional
          AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
          AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
      ) > 0
ORDER BY p.id_profesional;

-- CASO 3 pt2

UPDATE profesional p
SET sueldo =
    CASE
        WHEN (
            SELECT SUM(a.honorario)
            FROM asesoria a
            WHERE a.id_profesional = p.id_profesional
              AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
              AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
        ) < 1000000
        THEN ROUND(p.sueldo * 1.10)

        WHEN (
            SELECT SUM(a.honorario)
            FROM asesoria a
            WHERE a.id_profesional = p.id_profesional
              AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
              AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
        ) >= 1000000
        THEN ROUND(p.sueldo * 1.15)
    END
WHERE EXISTS (
    SELECT 1
    FROM asesoria a
    WHERE a.id_profesional = p.id_profesional
      AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
      AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
);

COMMIT;


--CASO 3 pt3

SELECT
    NVL((
        SELECT SUM(a.honorario)
        FROM asesoria a
        WHERE a.id_profesional = p.id_profesional
          AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
          AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
    ),0) AS honorario,

    p.id_profesional,
    p.numrun_prof,
    p.sueldo
FROM profesional p
WHERE (
        SELECT SUM(a.honorario)
        FROM asesoria a
        WHERE a.id_profesional = p.id_profesional
          AND EXTRACT(MONTH FROM a.fin_asesoria) = 3
          AND EXTRACT(YEAR  FROM a.fin_asesoria) = EXTRACT(YEAR FROM SYSDATE) - 1
      ) > 0
ORDER BY p.id_profesional;

----------------------------------------------------
----------CASO 1...---------------------------------
----------------------------------------------------
SELECT
    LPAD(TO_CHAR(c.numrun, '99G999G999') || '-' || c.dvrun, 15, ' ') AS "RUT Cliente",
    INITCAP(c.pnombre || ' ' || c.appaterno) AS "Nombre Cliente",
    UPPER(p.nombre_prof_ofic) AS "Profesion Cliente",
    TO_CHAR(c.fecha_inscripcion, 'DD-MM-YYYY') AS "Fecha de Inscripcion",
    INITCAP(c.direccion) AS "Direccion Cliente"
FROM
    CLIENTE c
    JOIN PROFESION_OFICIO p
        ON c.cod_prof_ofic = p.cod_prof_ofic
    JOIN TIPO_CLIENTE tc
        ON c.cod_tipo_cliente = tc.cod_tipo_cliente
WHERE
    tc.cod_tipo_cliente = 10
    AND UPPER(p.nombre_prof_ofic) IN ('CONTADOR', 'VENDEDOR')
    AND EXTRACT(YEAR FROM c.fecha_inscripcion) >
        (SELECT ROUND(AVG(EXTRACT(YEAR FROM fecha_inscripcion)))
         FROM CLIENTE)
ORDER BY
    c.numrun ASC;
    
----------------------------------------------------
----------CASO 2...---------------------------------
----------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE clientes_cupos_compra';
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END;
/
-- Creacion de la tabla para almacenar los resultados
CREATE TABLE clientes_cupos_compra AS
(
    SELECT
        LPAD(TO_CHAR(c.numrun, '99G999G999') || '-' || c.dvrun, 15, ' ') AS RUT_CLIENTE,
        EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM c.fecha_nacimiento) AS EDAD,
        TO_CHAR(t.cupo_disp_compra, 'FM$ 9G999G999')AS CUPO_DISPONIBLE_COMPRA,
        UPPER(tc.nombre_tipo_cliente) AS TIPO_CLIENTE
    FROM
        CLIENTE c
        JOIN TARJETA_CLIENTE t
            ON c.numrun = t.numrun
        JOIN TIPO_CLIENTE tc
            ON c.cod_tipo_cliente = tc.cod_tipo_cliente
    WHERE
        t.cupo_disp_compra >= (
            SELECT MAX(cupo_disp_compra)
            FROM TARJETA_CLIENTE
            WHERE EXTRACT(YEAR FROM fecha_solic_tarjeta) =
                  EXTRACT(YEAR FROM SYSDATE) - 1
        )
);

--Resultado
SELECT
    RUT_CLIENTE,
    EDAD,
    CUPO_DISPONIBLE_COMPRA,
    TIPO_CLIENTE
FROM
    clientes_cupos_compra
ORDER BY
    EDAD ASC;




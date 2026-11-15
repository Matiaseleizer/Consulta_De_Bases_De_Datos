--------------------------------------------------------
-- ACTIVIDAD FORMATIVA SEMANA 4: DESARROLLANDO JOINS EN LAS TABLAS
-- =====================================================
-- CASO 1: LISTADO DE TRABAJADORES
-- =====================================================
SELECT 
    UPPER(t.nombre || ' ' || t.appaterno || ' ' || NVL(t.apmaterno, '')) AS "Nombre Completo Trabajador",
    TO_CHAR(t.numrut, '99G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') || '-' || UPPER(t.dvrut) AS "RUT Trabajador",
    UPPER(tt.desc_categoria) AS "Tipo Trabajador",
    UPPER(c.nombre_ciudad) AS "Ciudad Trabajador",
    TO_CHAR(t.sueldo_base, '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Sueldo Base"
FROM trabajador t
INNER JOIN tipo_trabajador tt 
    ON t.id_categoria_t = tt.id_categoria
INNER JOIN comuna_ciudad c 
    ON t.id_ciudad = c.id_ciudad
WHERE t.sueldo_base BETWEEN 650000 AND 3000000
ORDER BY c.nombre_ciudad DESC, t.sueldo_base ASC;

-- =====================================================
-- CASO 2: LISTADO CAJEROS
-- =====================================================
SELECT 
    TO_CHAR(t.numrut, '99G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') || '-' || UPPER(t.dvrut) AS "RUT Trabajador",
    INITCAP(t.nombre) || ' ' || UPPER(t.appaterno) AS "Nombre Trabajador",
    COUNT(tc.nro_ticket) AS "Total Tickets",
    TO_CHAR(SUM(tc.monto_ticket), '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Total Vendido",
    TO_CHAR(SUM(NVL(ct.valor_comision, 0)), '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Comisión Total",
    UPPER(tt.desc_categoria) AS "Tipo Trabajador",
    UPPER(c.nombre_ciudad) AS "Ciudad Trabajador"
FROM trabajador t
INNER JOIN tipo_trabajador tt 
    ON t.id_categoria_t = tt.id_categoria
INNER JOIN comuna_ciudad c 
    ON t.id_ciudad = c.id_ciudad
INNER JOIN tickets_concierto tc 
    ON t.numrut = tc.numrut_t
LEFT JOIN comisiones_ticket ct 
    ON tc.nro_ticket = ct.nro_ticket
WHERE UPPER(tt.desc_categoria) = 'CAJERO'
GROUP BY 
    t.numrut, 
    t.dvrut, 
    t.nombre, 
    t.appaterno, 
    tt.desc_categoria, 
    c.nombre_ciudad
HAVING SUM(tc.monto_ticket) > 50000
ORDER BY SUM(tc.monto_ticket) DESC;

-- =====================================================
-- CASO 3: LISTADO DE BONIFICACIONES
-- =====================================================
SELECT 
    TO_CHAR(t.numrut, '99G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "RUT Trabajador",
    INITCAP(t.nombre || ' ' || t.appaterno) AS "Trabajador Nombre",
    EXTRACT(YEAR FROM t.fecing) AS "Año Ingreso",
    EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.fecing) AS "Años Antigüedad",
    COUNT(DISTINCT af.numrut_carga) AS "Num. Cargas Familiares",
    INITCAP(i.nombre_isapre) AS "Nombre Isapre",
    TO_CHAR(t.sueldo_base, '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Sueldo Base",
    CASE 
        WHEN UPPER(i.nombre_isapre) = 'FONASA' THEN 
            TO_CHAR(ROUND(t.sueldo_base * 0.01), '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''')
        ELSE 
            TO_CHAR(0, '999G999G999')
    END AS "Bono Fonasa",
    TO_CHAR(
        ROUND(
            CASE 
                WHEN (EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM t.fecing)) <= 10 THEN t.sueldo_base * 0.10
                ELSE t.sueldo_base * 0.15
            END
        ), 
        '$999G999G999', 
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "Bono Antigüedad",
    INITCAP(a.nombre_afp) AS "Nombre AFP",
    UPPER(eci.desc_estcivil) AS "Estado Civil"
FROM trabajador t
INNER JOIN isapre i 
    ON t.cod_isapre = i.cod_isapre
INNER JOIN afp a 
    ON t.cod_afp = a.cod_afp
INNER JOIN est_civil ec 
    ON t.numrut = ec.numrut_t
INNER JOIN estado_civil eci 
    ON ec.id_estcivil_est = eci.id_estcivil
LEFT JOIN asignacion_familiar af 
    ON t.numrut = af.numrut_t
WHERE ec.fecter_estcivil IS NULL 
   OR ec.fecter_estcivil > SYSDATE
GROUP BY 
    t.numrut, 
    t.nombre, 
    t.appaterno, 
    t.fecing, 
    i.nombre_isapre, 
    t.sueldo_base, 
    a.nombre_afp, 
    eci.desc_estcivil
ORDER BY t.numrut ASC;
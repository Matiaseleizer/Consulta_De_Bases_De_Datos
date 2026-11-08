-- =====================================================
-- CASO 1: ANÁLISIS DE PROPIEDADES
-- =====================================================
SELECT 
    id_tipo_propiedad AS "TIPO",
    COUNT(nro_propiedad) AS "TOTAL_PROPIEDADES",
    TO_CHAR(MAX(valor_arriendo), '$999G999G999') AS "MAX_ARRIENDO",
    TO_CHAR(ROUND(AVG(valor_arriendo)), '$999G999G999') AS "PROMEDIO_ARRIENDO",
    TO_CHAR(MIN(valor_arriendo), '$999G999G999') AS "MIN_ARRIENDO",
    CASE 
        WHEN MAX(valor_arriendo) <= 1000000 THEN 'ESTÁNDAR'
        ELSE 'PREMIUM'
    END AS "CLASIFICACION",
    TO_CHAR(SUM(valor_gasto_comun), '$999G999G999') AS "TOTAL_GASTOS_COMUNES"
FROM propiedad
GROUP BY id_tipo_propiedad
HAVING SUM(valor_gasto_comun) > &VALOR_TOTAL_GASTO_COMUN
ORDER BY SUM(valor_gasto_comun) DESC;

-- =====================================================
-- CASO 2: ANÁLISIS DE ANTIGÜEDAD DE EMPLEADOS
-- =====================================================
SELECT 
    UPPER(nombre_emp || ' ' || appaterno_emp) AS "Nombre Empleado",
    TO_CHAR(sueldo_emp, '$999G999G999') AS "Sueldo con Formato",
    CASE 
        WHEN sueldo_emp > 2000000 THEN 'ALTO'
        ELSE 'MEDIO'
    END AS "Clasificación Sueldo",
    TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) AS "Años Antigüedad",
    CASE 
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 5 AND 10 
            THEN 'Corresponde bono  5%: ' || TO_CHAR(ROUND(sueldo_emp * 0.05), '$999G999G999')
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) BETWEEN 11 AND 20 
            THEN 'Corresponde bono 10%: ' || TO_CHAR(ROUND(sueldo_emp * 0.10), '$999G999G999')
        WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) > 20 
            THEN 'Corresponde bono 15%: ' || TO_CHAR(ROUND(sueldo_emp * 0.15), '$999G999G999')
    END AS "BONO"
FROM empleado
WHERE id_categoria_emp = 3
  AND TRUNC(MONTHS_BETWEEN(SYSDATE, fecing_emp) / 12) > 5
  AND id_sucursal <> &CODIGO_SUCURSAL
ORDER BY sueldo_emp DESC;

-- =====================================================
-- CASO 3: LISTA DE CLIENTES
-- =====================================================
SELECT 
    CASE 
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli BETWEEN 600000 AND 999999 THEN 'ALTA'
        WHEN renta_cli BETWEEN 300000 AND 599999 THEN 'MEDIA'
        ELSE 'BAJA'
    END AS "CLASIFICACION_RENTA",
    COUNT(*) AS "CANTIDAD_CLIENTES",
    TO_CHAR(ROUND(AVG(renta_cli)), '$999G999G999') AS "RENTA_PROMEDIO",
    CASE 
        WHEN COUNT(fonofijo_cli) + COUNT(celular_cli) > 0 THEN 'Clientes con Teléfono'
        ELSE 'Clientes Sin Teléfono'
    END AS "ESTADO_TELEFONO"
FROM cliente
GROUP BY 
    CASE 
        WHEN renta_cli >= 1000000 THEN 'PREMIUM'
        WHEN renta_cli BETWEEN 600000 AND 999999 THEN 'ALTA'
        WHEN renta_cli BETWEEN 300000 AND 599999 THEN 'MEDIA'
        ELSE 'BAJA'
    END
HAVING AVG(renta_cli) > 200000;
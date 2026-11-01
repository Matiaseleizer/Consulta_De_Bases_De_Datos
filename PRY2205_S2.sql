SELECT 
    numfactura AS "N° Factura",
    INITCAP(TO_CHAR(fecha, 'DD "de" Month YYYY', 'NLS_DATE_LANGUAGE=SPANISH')) AS "Fecha Emisión",
    LPAD(rutcliente, 10, '0') AS "RUT Cliente",
    TO_CHAR(neto, '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Monto Neto",
    TO_CHAR(iva, '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Monto Iva",
    TO_CHAR(total, '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') AS "Total Factura",
    CASE 
        WHEN total BETWEEN 0 AND 50000 THEN 'Bajo'
        WHEN total BETWEEN 50001 AND 100000 THEN 'Medio'
        ELSE 'Alto'
    END AS "Categoría Monto",
    CASE codpago
        WHEN 1 THEN 'EFECTIVO'
        WHEN 2 THEN 'TARJETA DEBITO'
        WHEN 3 THEN 'TARJETA CREDITO'
        ELSE 'CHEQUE'
    END AS "Forma de pago"
FROM factura
WHERE EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM SYSDATE) - 1
ORDER BY fecha DESC, neto DESC;

/*---Esta consulta extrae los clientes con estado 'A' y crédito mayor a 0---*/
SELECT 
    LPAD(rutcliente, 12, '*') AS "RUT",
    nombre AS "Cliente",
    NVL(TO_CHAR(telefono), 'Sin teléfono') AS "TELÉFONO",
    NVL(TO_CHAR(codcomuna), 'Sin comuna') AS "COMUNA",
    estado AS "ESTADO",
    CASE 
        WHEN (saldo / credito) < 0.5 THEN 
            'Bueno ( ' || TO_CHAR(credito - saldo, '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') || ')'
        WHEN (saldo / credito) BETWEEN 0.5 AND 0.8 THEN 
            'Regular ( ' || TO_CHAR(saldo, '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') || ')'
        ELSE 
            'Crítico'
    END AS "Estado Crédito",
    CASE 
        WHEN mail IS NULL THEN 'Correo no registrado'
        ELSE UPPER(SUBSTR(mail, INSTR(mail, '@') + 1))
    END AS "Dominio Correo"
FROM cliente
WHERE estado = 'A' 
  AND credito > 0
ORDER BY nombre ASC;

/*---Stock de Productos---*/
SELECT 
    codproducto AS "ID",
    descripcion AS "Descripción de Producto",
    CASE 
        WHEN valorcompradolar IS NULL THEN 'Sin registro'
        ELSE REPLACE(TO_CHAR(valorcompradolar), '.', ',') || ' USD'
    END AS "Compra en USD",
    CASE 
        WHEN valorcompradolar IS NULL THEN 'Sin registro'
        ELSE TO_CHAR(ROUND(valorcompradolar * &TIPOCAMBIO_DOLAR), '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''') || ' PESOS'
    END AS "USD convertido",
    totalstock AS "Stock",
    CASE 
        WHEN totalstock IS NULL THEN 'Sin datos'
        WHEN totalstock < &UMBRAL_BAJO THEN '¡ALERTA stock muy bajo!'
        WHEN totalstock BETWEEN &UMBRAL_BAJO AND &UMBRAL_ALTO THEN '¡Reabastecer pronto!'
        ELSE 'OK'
    END AS "Alerta Stock",
    CASE 
        WHEN totalstock > 80 THEN TO_CHAR(ROUND(vunitario * 0.90), '$999G999G999', 'NLS_NUMERIC_CHARACTERS='',.''')
        ELSE 'N/A'
    END AS "Precio Oferta"
FROM producto
WHERE LOWER(descripcion) LIKE '%zapato%'
  AND LOWER(procedencia) = 'i'
ORDER BY codproducto DESC;
/*******************************************************************************
 * FUNCIÓN: obtener_total_clientes
 * 
 * DESCRIPCIÓN:
 * Obtiene el número total de clientes únicos en el sistema VivaTrend.
 * No requiere parámetros.
 * 
 * RETORNA: Número total de clientes (NUMBER)
 * 
 * VERSIÓN: 1.0 - Función standalone
 * FECHA: Octubre 2025
 ******************************************************************************/

CREATE OR REPLACE FUNCTION obtener_total_clientes
RETURN NUMBER IS
    v_total NUMBER := 0;
BEGIN
    SELECT COUNT(DISTINCT tc.NUMRUN)
    INTO v_total
    FROM TARJETA_CLIENTE tc;
    
    DBMS_OUTPUT.PUT_LINE('Total de clientes en sistema: ' || v_total);
    
    RETURN v_total;
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error obteniendo total de clientes: ' || SQLERRM);
        RETURN 0;
END obtener_total_clientes;
/

SHOW ERRORS;
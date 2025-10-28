/*******************************************************************************
 * PROCEDIMIENTO: obtener_resumen_cliente
 * 
 * DESCRIPCIÓN:
 * Obtiene un resumen completo de la información de un cliente específico,
 * incluyendo sus datos personales, tarjeta y estadísticas de pagos.
 * 
 * PARÁMETROS:
 * - p_rut_cliente (IN): RUT del cliente a consultar
 * - p_info_cliente (OUT): Registro con toda la información del cliente
 * 
 * VERSIÓN: 1.0 - Procedimiento standalone
 * FECHA: Octubre 2025
 ******************************************************************************/

CREATE OR REPLACE PROCEDURE obtener_resumen_cliente(
    p_rut_cliente IN NUMBER,
    p_info_cliente OUT PKG_VIVATREND_TARJETAS.t_cliente_resumen
) AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Obteniendo resumen para cliente: ' || p_rut_cliente);
    
    SELECT 
        p_rut_cliente,
        (SELECT NOMBRE || ' ' || APELLIDO_PAT || ' ' || APELLIDO_MAT 
         FROM CLIENTE WHERE NUMRUN = p_rut_cliente),
        tc.NRO_TARJETA,
        COUNT(pmt.NRO_SECUENCIA_PAGO),
        NVL(SUM(pmt.MONTO_PAGADO), 0),
        NVL(AVG(pmt.MONTO_PAGADO), 0),
        MAX(pmt.FECHA_PAGO),
        'N/A' -- Se ha eliminado la dependencia a obtener_metodo_preferido
    INTO
        p_info_cliente.rut_cliente,
        p_info_cliente.nombre_completo,
        p_info_cliente.nro_tarjeta,
        p_info_cliente.total_pagos,
        p_info_cliente.monto_total,
        p_info_cliente.promedio_pago,
        p_info_cliente.ultimo_pago,
        p_info_cliente.metodo_preferido
    FROM TARJETA_CLIENTE tc
    LEFT JOIN PAGO_MENSUAL_TARJETA_CLIENTE pmt ON tc.NRO_TARJETA = pmt.NRO_TARJETA
    WHERE tc.NUMRUN = p_rut_cliente
    GROUP BY tc.NRO_TARJETA;
    
    DBMS_OUTPUT.PUT_LINE('Resumen obtenido: Total pagos=' || p_info_cliente.total_pagos);
    
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_info_cliente.rut_cliente := p_rut_cliente;
        p_info_cliente.nombre_completo := 'Cliente no encontrado';
        p_info_cliente.total_pagos := 0;
        p_info_cliente.monto_total := 0;
        DBMS_OUTPUT.PUT_LINE('Cliente no encontrado');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al obtener resumen: ' || SQLERRM);
        RAISE;
END obtener_resumen_cliente;
/

SHOW ERRORS;
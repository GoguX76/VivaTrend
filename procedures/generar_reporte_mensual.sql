/*******************************************************************************
 * PROCEDIMIENTO: generar_reporte_mensual
 * 
 * DESCRIPCIÓN:
 * Genera un reporte mensual con todos los pagos del mes actual,
 * mostrando información detallada por cliente y tarjeta.
 * 
 * VERSIÓN: 1.0 - Procedimiento standalone
 * FECHA: Octubre 2025
 ******************************************************************************/

CREATE OR REPLACE PROCEDURE generar_reporte_mensual AS
    v_mes_actual VARCHAR2(6);
    v_total_pagos NUMBER := 0;
    v_monto_total NUMBER := 0;
    v_promedio NUMBER := 0;
    
    CURSOR c_pagos_mes IS
        SELECT 
            tc.NUMRUN,
            tc.NRO_TARJETA,
            COUNT(*) as cantidad_pagos,
            SUM(pmt.MONTO_PAGADO) as total_pagado
        FROM TARJETA_CLIENTE tc
        JOIN PAGO_MENSUAL_TARJETA_CLIENTE pmt ON tc.NRO_TARJETA = pmt.NRO_TARJETA
        WHERE pmt.ANNO_MES_PAGO = TO_CHAR(SYSDATE, 'YYYYMM')
        GROUP BY tc.NUMRUN, tc.NRO_TARJETA
        ORDER BY total_pagado DESC;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== GENERANDO REPORTE MENSUAL ===');
    v_mes_actual := TO_CHAR(SYSDATE, 'YYYYMM');
    
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('  REPORTE MENSUAL DE PAGOS VIVATREND');
    DBMS_OUTPUT.PUT_LINE('  Período: ' || TO_CHAR(SYSDATE, 'MONTH YYYY'));
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('');
    
    FOR reg IN c_pagos_mes LOOP
        v_total_pagos := v_total_pagos + reg.cantidad_pagos;
        v_monto_total := v_monto_total + reg.total_pagado;
        
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || reg.NUMRUN || 
                           ' | Tarjeta: ' || reg.NRO_TARJETA ||
                           ' | Pagos: ' || reg.cantidad_pagos ||
                           ' | Total: $' || TO_CHAR(reg.total_pagado, '999,999,999'));
    END LOOP;
    
    IF v_total_pagos > 0 THEN
        v_promedio := v_monto_total / v_total_pagos;
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('========================================');
    DBMS_OUTPUT.PUT_LINE('TOTALES:');
    DBMS_OUTPUT.PUT_LINE('  Total de pagos: ' || v_total_pagos);
    DBMS_OUTPUT.PUT_LINE('  Monto total: $' || TO_CHAR(v_monto_total, '999,999,999'));
    DBMS_OUTPUT.PUT_LINE('  Promedio: $' || TO_CHAR(v_promedio, '999,999,999'));
    DBMS_OUTPUT.PUT_LINE('========================================');
    
    DBMS_OUTPUT.PUT_LINE('Reporte generado exitosamente');
    
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR al generar reporte: ' || SQLERRM);
        RAISE;
END generar_reporte_mensual;
/

SHOW ERRORS;
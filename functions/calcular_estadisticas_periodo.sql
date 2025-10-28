/*******************************************************************************
 * FUNCIÓN: calcular_estadisticas_periodo
 * * DESCRIPCIÓN:
 * Calcula estadísticas agregadas de pagos para un período específico.
 * Retorna un registro con totales, promedios y valores extremos.
 ******************************************************************************/

CREATE OR REPLACE FUNCTION calcular_estadisticas_periodo(
    p_fecha_inicio IN DATE,
    p_fecha_fin IN DATE
) RETURN PKG_VIVATREND_TARJETAS.t_estadisticas_pago IS
    v_stats PKG_VIVATREND_TARJETAS.t_estadisticas_pago;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Calculando estadísticas para período...');
    
    SELECT 
        COUNT(*),
        NVL(SUM(MONTO_PAGADO), 0),
        NVL(AVG(MONTO_PAGADO), 0),
        NVL(MAX(MONTO_PAGADO), 0),
        NVL(MIN(MONTO_PAGADO), 0),
        -- Si no hay pagos, usa las fechas de entrada como período
        NVL(MIN(FECHA_PAGO), p_fecha_inicio), 
        NVL(MAX(FECHA_PAGO), p_fecha_fin)
    INTO
        v_stats.total_pagos,
        v_stats.monto_total,
        v_stats.monto_promedio,
        v_stats.monto_maximo,
        v_stats.monto_minimo,
        v_stats.periodo_inicio,
        v_stats.periodo_fin
    FROM PAGO_MENSUAL_TARJETA_CLIENTE
    WHERE FECHA_PAGO BETWEEN p_fecha_inicio AND p_fecha_fin;
    
    DBMS_OUTPUT.PUT_LINE('Estadísticas calculadas: Total pagos=' || v_stats.total_pagos);
    
    RETURN v_stats;
    
EXCEPTION

    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error calculando estadísticas: ' || SQLERRM);
        RAISE;
END calcular_estadisticas_periodo;
/

SHOW ERRORS;
/*******************************************************************************
 * PACKAGE: PKG_VIVATREND_TARJETAS
 ******************************************************************************/

CREATE OR REPLACE PACKAGE PKG_VIVATREND_TARJETAS AS

    /***************************************************************************
     * TIPOS DE DATOS
     ***************************************************************************/
    
    -- Tipo para resumen de cliente
    TYPE t_cliente_resumen IS RECORD(
        rut_cliente NUMBER,
        nombre_completo VARCHAR2(200),
        nro_tarjeta NUMBER,
        total_pagos NUMBER,
        monto_total NUMBER(12,2),
        promedio_pago NUMBER(12,2),
        ultimo_pago DATE,
        metodo_preferido VARCHAR2(50)
    );

    -- Tipo para información de cupos
    TYPE t_info_cupos IS RECORD (
        nro_tarjeta NUMBER,
        cupo_max_compra NUMBER(12,2),
        cupo_disp_compra NUMBER(12,2),
        cupo_max_avance NUMBER(12,2),
        cupo_disp_avance NUMBER(12,2),
        porcentaje_uso_compra NUMBER(5,2),
        porcentaje_uso_avance NUMBER(5,2),
        estado VARCHAR2(50)
    );
    
    -- Colección para múltiples clientes (PIPELINED)
    TYPE t_tabla_clientes IS TABLE OF t_cliente_resumen;

    -- Tipo para estadísticas de pagos
    TYPE t_estadisticas_pago IS RECORD (
        total_pagos NUMBER,
        monto_total NUMBER(12,2),
        monto_promedio NUMBER(12,2),
        monto_maximo NUMBER(12,2),
        monto_minimo NUMBER(12,2),
        periodo_inicio DATE,
        periodo_fin DATE
    );

    /***************************************************************************
     * CONSTANTES
     ***************************************************************************/
    
    -- Códigos de formas de pago
    C_PAGO_EFECTIVO CONSTANT NUMBER := 1;
    C_PAGO_CHEQUE CONSTANT NUMBER := 2;
    C_PAGO_TRANSFERENCIA CONSTANT NUMBER := 3;
    
    -- Cupos por defecto
    C_CUPO_DEFAULT_COMPRA CONSTANT NUMBER := 1000000;
    C_CUPO_DEFAULT_AVANCE CONSTANT NUMBER := 500000;
    
    -- Porcentajes de distribución
    C_PORCENTAJE_COMPRA CONSTANT NUMBER := 0.70;
    C_PORCENTAJE_AVANCE CONSTANT NUMBER := 0.30;
    
    -- Límites de montos
    C_MONTO_MINIMO_PAGO CONSTANT NUMBER := 1000;
    C_MONTO_MAXIMO_PAGO CONSTANT NUMBER := 999999999;
    
    -- Meses de vencimiento
    C_MESES_VENCIMIENTO CONSTANT NUMBER := 5;

    /***************************************************************************
     * PROCEDIMIENTOS Y FUNCIONES PÚBLICAS
     ***************************************************************************/
    
    -- Función para validar si una tarjeta está activa y tiene cupo disponible
    FUNCTION validar_tarjeta_activa(p_nro_tarjeta IN NUMBER) RETURN BOOLEAN;
    
    -- Procedimiento para actualizar cupos después de un pago
    PROCEDURE actualizar_cupos_pago(
        p_nro_tarjeta IN NUMBER,
        p_monto_pago IN NUMBER
    );

END PKG_VIVATREND_TARJETAS;
/

CREATE OR REPLACE PACKAGE BODY PKG_VIVATREND_TARJETAS AS

    /***************************************************************************
     * FUNCIÓN: validar_tarjeta_activa
     * DESCRIPCIÓN: Verifica si una tarjeta está activa y tiene cupo disponible
     ***************************************************************************/
    FUNCTION validar_tarjeta_activa(p_nro_tarjeta IN NUMBER) RETURN BOOLEAN IS
        v_existe NUMBER := 0;
        v_cupo_disponible NUMBER := 0;
    BEGIN
        -- Verificar si la tarjeta existe y tiene cupo disponible
        SELECT COUNT(*), NVL(MAX(CUPO_DISP_COMPRA), 0)
        INTO v_existe, v_cupo_disponible
        FROM TARJETA_CLIENTE
        WHERE NRO_TARJETA = p_nro_tarjeta;
        
        -- Retorna TRUE si existe y tiene cupo mayor a 0
        RETURN (v_existe > 0 AND v_cupo_disponible > 0);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN FALSE;
    END validar_tarjeta_activa;

    /***************************************************************************
     * PROCEDIMIENTO: actualizar_cupos_pago
     * DESCRIPCIÓN: Actualiza los cupos disponibles después de realizar un pago
     ***************************************************************************/
    PROCEDURE actualizar_cupos_pago(
        p_nro_tarjeta IN NUMBER,
        p_monto_pago IN NUMBER
    ) IS
        v_cupo_actual_compra NUMBER;
        v_cupo_actual_avance NUMBER;
        v_monto_compra NUMBER;
        v_monto_avance NUMBER;
    BEGIN
        -- Obtener cupos actuales
        SELECT CUPO_DISP_COMPRA, CUPO_DISP_SP_AVANCE
        INTO v_cupo_actual_compra, v_cupo_actual_avance
        FROM TARJETA_CLIENTE
        WHERE NRO_TARJETA = p_nro_tarjeta;
        
        -- Distribuir el pago entre compra y avance según porcentajes
        v_monto_compra := p_monto_pago * C_PORCENTAJE_COMPRA;
        v_monto_avance := p_monto_pago * C_PORCENTAJE_AVANCE;
        
        -- Actualizar cupos disponibles (aumentan con el pago)
        UPDATE TARJETA_CLIENTE
        SET CUPO_DISP_COMPRA = LEAST(CUPO_COMPRA, v_cupo_actual_compra + v_monto_compra),
            CUPO_DISP_SP_AVANCE = LEAST(CUPO_SUPER_AVANCE, v_cupo_actual_avance + v_monto_avance)
        WHERE NRO_TARJETA = p_nro_tarjeta;
        
        DBMS_OUTPUT.PUT_LINE('Cupos actualizados para tarjeta: ' || p_nro_tarjeta);
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Tarjeta no encontrada: ' || p_nro_tarjeta);
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'Error al actualizar cupos: ' || SQLERRM);
    END actualizar_cupos_pago;

END PKG_VIVATREND_TARJETAS;
/

SHOW ERRORS;
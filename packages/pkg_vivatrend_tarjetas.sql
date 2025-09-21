-- Package para manejar tarjetas y pagos VivaTrend
CREATE OR REPLACE PACKAGE PKG_VIVATREND_TARJETAS AS

    -- Tipo para información de cliente
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
        porcentaje_uso_avance NUMBER(5,2)
    );

    -- Tablas para múltiples resultados (para PIPELINED debe ser sin INDEX BY)
    TYPE t_tabla_clientes IS TABLE OF t_cliente_resumen;

    -- Constantes
    C_PAGO_EFECTIVO CONSTANT NUMBER := 1;
    C_PAGO_CHEQUE CONSTANT NUMBER := 2;
    C_PAGO_TRANSFERENCIA CONSTANT NUMBER := 3;
    C_CUPO_DEFAULT_COMPRA CONSTANT NUMBER := 1000000;
    C_CUPO_DEFAULT_AVANCE CONSTANT NUMBER := 500000;

    -- PROCEDIMIENTOS
    
    -- Registra un pago (versión mejorada)
    PROCEDURE registrar_pago_mejorado(
        p_rut_cliente IN NUMBER,
        p_nro_tarjeta IN OUT NUMBER,
        p_cod_forma_pago IN OUT NUMBER,
        p_monto IN NUMBER,
        p_fecha_pago IN DATE,
        p_resultado OUT VARCHAR2
    );
    
    -- Obtiene resumen completo de un cliente
    PROCEDURE obtener_resumen_cliente(
        p_rut_cliente IN NUMBER,
        p_info_cliente OUT t_cliente_resumen
    );

    -- FUNCIONES
    
    -- Calcula cupo total disponible de una tarjeta
    FUNCTION calcular_cupo_total_disponible(
        p_nro_tarjeta IN NUMBER
    ) RETURN NUMBER;
    
    -- Obtiene método de pago más usado por cliente
    FUNCTION obtener_metodo_preferido(
        p_rut_cliente IN NUMBER
    ) RETURN VARCHAR2;
    
    -- Valida si un monto es válido para pago
    FUNCTION validar_monto_pago(
        p_monto IN NUMBER
    ) RETURN BOOLEAN;
    
    -- Obtiene información detallada de cupos
    FUNCTION obtener_info_cupos(
        p_nro_tarjeta IN NUMBER
    ) RETURN t_info_cupos;
    
    -- Calcula promedio de pagos de un cliente
    FUNCTION calcular_promedio_pagos(
        p_rut_cliente IN NUMBER
    ) RETURN NUMBER;
    
    -- Obtiene descripción de forma de pago
    FUNCTION obtener_desc_forma_pago(
        p_cod_forma_pago IN NUMBER
    ) RETURN VARCHAR2;
    
    -- Verifica si existe una tarjeta
    FUNCTION existe_tarjeta(
        p_nro_tarjeta IN NUMBER
    ) RETURN BOOLEAN;
    
    -- Obtiene todos los clientes con resumen
    FUNCTION obtener_todos_clientes_resumen
    RETURN t_tabla_clientes PIPELINED;
    
    -- Cuenta pagos en un período
    FUNCTION contar_pagos_periodo(
        p_fecha_inicio IN DATE,
        p_fecha_fin IN DATE
    ) RETURN NUMBER;

END PKG_VIVATREND_TARJETAS;
/
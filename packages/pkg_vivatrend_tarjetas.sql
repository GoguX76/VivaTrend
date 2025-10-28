/*******************************************************************************
 * PACKAGE: PKG_VIVATREND_TARJETAS
 * 
 * CONTEXTO DE NEGOCIO:
 * --------------------
 * VivaTrend es una empresa retail que ofrece tarjetas de crédito a sus clientes
 * para facilitar sus compras. El sistema gestiona:
 * 
 * 1. TARJETAS DE CRÉDITO: Cada cliente puede tener una tarjeta con dos tipos de cupos:
 *    - Cupo de Compra: Para realizar compras en tiendas
 *    - Cupo de Super Avance: Para retiros de efectivo
 * 
 * 2. PAGOS MENSUALES: Los clientes realizan pagos que incrementan sus cupos disponibles
 *    según una distribución: 70% para compras y 30% para avances
 * 
 * 3. MÉTODOS DE PAGO: Los pagos pueden realizarse mediante:
 *    - Efectivo
 *    - Cheque
 *    - Transferencia bancaria
 * 
 * Este package contiene solo tipos de datos y constantes.
 * Las funciones y procedimientos están en archivos separados por modularidad.
 * 
 * VERSIÓN: 3.0 - Refactorizado para eliminar funciones y procedimientos no esenciales
 * FECHA: Octubre 2025
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

END PKG_VIVATREND_TARJETAS;
/

SHOW ERRORS;

/*******************************************************************************
 * NOTA: Este package no requiere un PACKAGE BODY porque solo contiene
 * definiciones de tipos y constantes. Todos los procedimientos y funciones
 * han sido movidos a archivos independientes en las carpetas 
 * /procedures y /functions para mejor modularidad.
 ******************************************************************************/
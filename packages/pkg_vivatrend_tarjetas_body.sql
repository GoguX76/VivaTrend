-- Package Body para PKG_VIVATREND_TARJETAS
CREATE OR REPLACE PACKAGE BODY PKG_VIVATREND_TARJETAS AS

    -- Variables privadas
    g_debug_mode BOOLEAN := TRUE;
    g_contador_operaciones NUMBER := 0;

    -- Función privada para logging
    PROCEDURE log_interno(p_mensaje IN VARCHAR2) IS
    BEGIN
        IF g_debug_mode THEN
            DBMS_OUTPUT.PUT_LINE('[VIVATREND] ' || TO_CHAR(SYSDATE, 'HH24:MI:SS') || ' - ' || p_mensaje);
        END IF;
    END log_interno;
    
    -- Función privada para incrementar contador
    PROCEDURE incrementar_contador IS
    BEGIN
        g_contador_operaciones := g_contador_operaciones + 1;
    END incrementar_contador;

    -- IMPLEMENTACIÓN DE PROCEDIMIENTOS
    
    PROCEDURE registrar_pago_mejorado(
        p_rut_cliente IN NUMBER,
        p_nro_tarjeta IN OUT NUMBER,
        p_cod_forma_pago IN OUT NUMBER,
        p_monto IN NUMBER,
        p_fecha_pago IN DATE,
        p_resultado OUT VARCHAR2
    ) AS
        v_anno_mes_pago VARCHAR2(6);
        v_fecha_vencimiento_pago DATE;
        v_existe NUMBER := 0;
    BEGIN
        log_interno('Iniciando registro de pago para cliente: ' || p_rut_cliente);
        incrementar_contador;
        
        -- Validar monto
        IF NOT validar_monto_pago(p_monto) THEN
            p_resultado := 'Error: Monto inválido. Debe ser mayor a 0';
            RETURN;
        END IF;
        
        -- Generar número de tarjeta si es necesario
        IF p_nro_tarjeta IS NULL OR p_nro_tarjeta = 0 THEN
            p_nro_tarjeta := SEQ_TARJETA_CLIENTE.NEXTVAL;
            log_interno('Generado nuevo número de tarjeta: ' || p_nro_tarjeta);
        END IF;

        -- Verificar si la tarjeta existe
        SELECT COUNT(*) INTO v_existe
        FROM TARJETA_CLIENTE
        WHERE NRO_TARJETA = p_nro_tarjeta;

        -- Crear tarjeta si no existe
        IF v_existe = 0 THEN
            INSERT INTO TARJETA_CLIENTE(
                NRO_TARJETA, NUMRUN, FECHA_SOLIC_TARJETA, DIA_PAGO_MENSUAL,
                CUPO_COMPRA, CUPO_SUPER_AVANCE, CUPO_DISP_COMPRA, CUPO_DISP_SP_AVANCE, ID_ETARJETA
            ) VALUES (
                p_nro_tarjeta, p_rut_cliente, SYSDATE, 1, 
                C_CUPO_DEFAULT_COMPRA, C_CUPO_DEFAULT_AVANCE, 
                C_CUPO_DEFAULT_COMPRA, C_CUPO_DEFAULT_AVANCE, 1
            );
            log_interno('Creada nueva tarjeta para cliente');
        END IF;

        -- Validar y asignar forma de pago
        IF p_cod_forma_pago IS NULL OR p_cod_forma_pago NOT BETWEEN 1 AND 3 THEN
            p_cod_forma_pago := TRUNC(DBMS_RANDOM.VALUE(1,4));
            log_interno('Asignada forma de pago: ' || obtener_desc_forma_pago(p_cod_forma_pago));
        END IF;

        -- Calcular campos derivados
        v_anno_mes_pago := TO_CHAR(p_fecha_pago, 'YYYYMM');
        v_fecha_vencimiento_pago := ADD_MONTHS(p_fecha_pago, 5);

        -- Insertar el pago
        INSERT INTO PAGO_MENSUAL_TARJETA_CLIENTE(
            NRO_SECUENCIA_PAGO, NRO_TARJETA, COD_FORMA_PAGO, MONTO_PAGADO, 
            FECHA_PAGO, ANNO_MES_PAGO, FECHA_VENCIMIENTO
        ) VALUES(
            SEQ_PAGO_MENSUAL.NEXTVAL, p_nro_tarjeta, p_cod_forma_pago, 
            p_monto, p_fecha_pago, v_anno_mes_pago, v_fecha_vencimiento_pago
        );

        COMMIT;
        p_resultado := 'Pago registrado exitosamente. Tarjeta: ' || p_nro_tarjeta || 
                      ', Monto: $' || TO_CHAR(p_monto, '999,999,999');
        
        log_interno('Pago registrado exitosamente');

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            p_resultado := 'Error al registrar el pago: ' || SQLERRM;
            log_interno('ERROR: ' || SQLERRM);
    END registrar_pago_mejorado;
    
    PROCEDURE obtener_resumen_cliente(
        p_rut_cliente IN NUMBER,
        p_info_cliente OUT t_cliente_resumen
    ) AS
    BEGIN
        log_interno('Obteniendo resumen para cliente: ' || p_rut_cliente);
        
        SELECT 
            p_rut_cliente,
            'Cliente ' || p_rut_cliente,
            tc.NRO_TARJETA,
            COUNT(pmt.NRO_SECUENCIA_PAGO),
            NVL(SUM(pmt.MONTO_PAGADO), 0),
            NVL(AVG(pmt.MONTO_PAGADO), 0),
            MAX(pmt.FECHA_PAGO),
            obtener_metodo_preferido(p_rut_cliente)
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
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_info_cliente.rut_cliente := p_rut_cliente;
            p_info_cliente.nombre_completo := 'Cliente no encontrado';
            p_info_cliente.total_pagos := 0;
            p_info_cliente.monto_total := 0;
    END obtener_resumen_cliente;

    -- IMPLEMENTACIÓN DE FUNCIONES
    
    FUNCTION calcular_cupo_total_disponible(
        p_nro_tarjeta IN NUMBER
    ) RETURN NUMBER AS
        v_cupo_total NUMBER := 0;
    BEGIN
        SELECT (CUPO_DISP_COMPRA + CUPO_DISP_SP_AVANCE)
        INTO v_cupo_total
        FROM TARJETA_CLIENTE
        WHERE NRO_TARJETA = p_nro_tarjeta;
        
        RETURN v_cupo_total;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RETURN -1;
    END calcular_cupo_total_disponible;
    
    FUNCTION obtener_metodo_preferido(
        p_rut_cliente IN NUMBER
    ) RETURN VARCHAR2 AS
        v_metodo_cod NUMBER;
        v_resultado VARCHAR2(50) := 'Sin pagos registrados';
    BEGIN
        -- Obtener el método más usado
        SELECT COD_FORMA_PAGO
        INTO v_metodo_cod
        FROM (
            SELECT pmt.COD_FORMA_PAGO, COUNT(*) as cantidad
            FROM TARJETA_CLIENTE tc
            JOIN PAGO_MENSUAL_TARJETA_CLIENTE pmt ON tc.NRO_TARJETA = pmt.NRO_TARJETA
            WHERE tc.NUMRUN = p_rut_cliente
            GROUP BY pmt.COD_FORMA_PAGO
            ORDER BY cantidad DESC
        )
        WHERE ROWNUM = 1;
        
        RETURN obtener_desc_forma_pago(v_metodo_cod);
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN v_resultado;
    END obtener_metodo_preferido;
    
    FUNCTION validar_monto_pago(
        p_monto IN NUMBER
    ) RETURN BOOLEAN AS
    BEGIN
        RETURN (p_monto > 0 AND p_monto <= 999999999);
    END validar_monto_pago;
    
    FUNCTION obtener_info_cupos(
        p_nro_tarjeta IN NUMBER
    ) RETURN t_info_cupos AS
        v_info t_info_cupos;
    BEGIN
        SELECT 
            NRO_TARJETA,
            CUPO_COMPRA,
            CUPO_DISP_COMPRA,
            CUPO_SUPER_AVANCE,
            CUPO_DISP_SP_AVANCE,
            ROUND((CUPO_DISP_COMPRA / CUPO_COMPRA) * 100, 2),
            ROUND((CUPO_DISP_SP_AVANCE / CUPO_SUPER_AVANCE) * 100, 2)
        INTO
            v_info.nro_tarjeta,
            v_info.cupo_max_compra,
            v_info.cupo_disp_compra,
            v_info.cupo_max_avance,
            v_info.cupo_disp_avance,
            v_info.porcentaje_uso_compra,
            v_info.porcentaje_uso_avance
        FROM TARJETA_CLIENTE
        WHERE NRO_TARJETA = p_nro_tarjeta;
        
        RETURN v_info;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            v_info.nro_tarjeta := 0;
            RETURN v_info;
    END obtener_info_cupos;
    
    FUNCTION calcular_promedio_pagos(
        p_rut_cliente IN NUMBER
    ) RETURN NUMBER AS
        v_promedio NUMBER := 0;
    BEGIN
        SELECT AVG(pmt.MONTO_PAGADO)
        INTO v_promedio
        FROM TARJETA_CLIENTE tc
        JOIN PAGO_MENSUAL_TARJETA_CLIENTE pmt ON tc.NRO_TARJETA = pmt.NRO_TARJETA
        WHERE tc.NUMRUN = p_rut_cliente;
        
        RETURN NVL(v_promedio, 0);
        
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END calcular_promedio_pagos;
    
    FUNCTION obtener_desc_forma_pago(
        p_cod_forma_pago IN NUMBER
    ) RETURN VARCHAR2 AS
    BEGIN
        CASE p_cod_forma_pago
            WHEN C_PAGO_EFECTIVO THEN RETURN 'Efectivo';
            WHEN C_PAGO_CHEQUE THEN RETURN 'Cheque';
            WHEN C_PAGO_TRANSFERENCIA THEN RETURN 'Transferencia';
            ELSE RETURN 'Forma de pago desconocida';
        END CASE;
    END obtener_desc_forma_pago;
    
    FUNCTION existe_tarjeta(
        p_nro_tarjeta IN NUMBER
    ) RETURN BOOLEAN AS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM TARJETA_CLIENTE
        WHERE NRO_TARJETA = p_nro_tarjeta;
        
        RETURN (v_count > 0);
    END existe_tarjeta;
    
    FUNCTION obtener_todos_clientes_resumen
    RETURN t_tabla_clientes PIPELINED AS
        v_cliente t_cliente_resumen;
    BEGIN
        FOR rec IN (
            SELECT DISTINCT tc.NUMRUN
            FROM TARJETA_CLIENTE tc
            ORDER BY tc.NUMRUN
        ) LOOP
            obtener_resumen_cliente(rec.NUMRUN, v_cliente);
            PIPE ROW(v_cliente);
        END LOOP;
        
        RETURN;
    END obtener_todos_clientes_resumen;
    
    FUNCTION contar_pagos_periodo(
        p_fecha_inicio IN DATE,
        p_fecha_fin IN DATE
    ) RETURN NUMBER AS
        v_total NUMBER := 0;
    BEGIN
        SELECT COUNT(*)
        INTO v_total
        FROM PAGO_MENSUAL_TARJETA_CLIENTE
        WHERE FECHA_PAGO BETWEEN p_fecha_inicio AND p_fecha_fin;
        
        RETURN v_total;
    END contar_pagos_periodo;

END PKG_VIVATREND_TARJETAS;
/
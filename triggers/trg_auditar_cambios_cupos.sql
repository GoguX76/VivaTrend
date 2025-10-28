/*******************************************************************************
 * TRIGGER: TRG_AUDITAR_CAMBIOS_CUPOS
 * 
 * DESCRIPCIÓN:
 * Este trigger registra automáticamente cualquier cambio en los límites
 * de cupos de las tarjetas (CUPO_COMPRA o CUPO_SUPER_AVANCE).
 * Útil para auditoría y control de cambios en el sistema.
 * 
 * EVENTO: BEFORE UPDATE ON TARJETA_CLIENTE
 * TIPO: FOR EACH ROW
 * 
 * FUNCIONALIDAD:
 * - Detecta cambios en los cupos máximos de la tarjeta
 * - Valida que los nuevos cupos sean positivos y mayores que los disponibles
 * - Registra la fecha y hora del cambio
 * - Muestra información detallada de los cambios realizados
 * - Previene cambios inválidos (cupos negativos o menores al disponible)
 * 
 * CONTEXTO DE NEGOCIO:
 * VivaTrend puede ajustar los límites de crédito de sus clientes
 * basándose en su comportamiento de pago. Este trigger asegura que:
 * 1. Los cambios sean válidos (no negativos)
 * 2. No se reduzcan por debajo del cupo ya utilizado
 * 3. Quede registro de todos los ajustes realizados
 * 
 * VERSIÓN: 1.0
 * FECHA: Octubre 2025
 ******************************************************************************/

CREATE OR REPLACE TRIGGER TRG_AUDITAR_CAMBIOS_CUPOS
    BEFORE UPDATE OF CUPO_COMPRA, CUPO_SUPER_AVANCE ON TARJETA_CLIENTE
    FOR EACH ROW
DECLARE
    v_cambio_compra BOOLEAN := FALSE;
    v_cambio_avance BOOLEAN := FALSE;
    v_diferencia_compra NUMBER := 0;
    v_diferencia_avance NUMBER := 0;
    v_tipo_cambio_compra VARCHAR2(20);
    v_tipo_cambio_avance VARCHAR2(20);
    
BEGIN
    /*
    PASO 1: DETECTAR SI HUBO CAMBIOS EN LOS CUPOS
    Comparamos los valores antiguos (:OLD) con los nuevos (:NEW)
    */
    IF :NEW.CUPO_COMPRA != :OLD.CUPO_COMPRA THEN
        v_cambio_compra := TRUE;
        v_diferencia_compra := :NEW.CUPO_COMPRA - :OLD.CUPO_COMPRA;
        
        IF v_diferencia_compra > 0 THEN
            v_tipo_cambio_compra := 'INCREMENTO';
        ELSE
            v_tipo_cambio_compra := 'REDUCCIÓN';
        END IF;
    END IF;
    
    IF :NEW.CUPO_SUPER_AVANCE != :OLD.CUPO_SUPER_AVANCE THEN
        v_cambio_avance := TRUE;
        v_diferencia_avance := :NEW.CUPO_SUPER_AVANCE - :OLD.CUPO_SUPER_AVANCE;
        
        IF v_diferencia_avance > 0 THEN
            v_tipo_cambio_avance := 'INCREMENTO';
        ELSE
            v_tipo_cambio_avance := 'REDUCCIÓN';
        END IF;
    END IF;
    
    /*
    PASO 2: VALIDACIONES DE NEGOCIO
    Aseguramos que los cambios sean válidos
    */
    
    -- Validación 1: Los cupos no pueden ser negativos
    IF :NEW.CUPO_COMPRA < 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 
            'ERROR: El cupo de compra no puede ser negativo. Valor ingresado: ' || 
            TO_CHAR(:NEW.CUPO_COMPRA));
    END IF;
    
    IF :NEW.CUPO_SUPER_AVANCE < 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 
            'ERROR: El cupo de super avance no puede ser negativo. Valor ingresado: ' || 
            TO_CHAR(:NEW.CUPO_SUPER_AVANCE));
    END IF;
    
    -- Validación 2: El cupo máximo no puede ser menor al cupo disponible
    -- (No podemos establecer un límite menor al dinero que ya está disponible)
    IF :NEW.CUPO_COMPRA < :NEW.CUPO_DISP_COMPRA THEN
        RAISE_APPLICATION_ERROR(-20003, 
            'ERROR: El cupo máximo de compra (' || TO_CHAR(:NEW.CUPO_COMPRA) || 
            ') no puede ser menor al cupo disponible (' || 
            TO_CHAR(:NEW.CUPO_DISP_COMPRA) || ')');
    END IF;
    
    IF :NEW.CUPO_SUPER_AVANCE < :NEW.CUPO_DISP_SP_AVANCE THEN
        RAISE_APPLICATION_ERROR(-20004, 
            'ERROR: El cupo máximo de super avance (' || TO_CHAR(:NEW.CUPO_SUPER_AVANCE) || 
            ') no puede ser menor al cupo disponible (' || 
            TO_CHAR(:NEW.CUPO_DISP_SP_AVANCE) || ')');
    END IF;
    
    /*
    PASO 3: REGISTRAR FECHA DE MODIFICACIÓN
    Actualizamos la fecha de la última modificación
    */
    :NEW.FECHA_MODIFICACION := SYSDATE;
    
    /*
    PASO 4: MOSTRAR INFORMACIÓN DE AUDITORÍA
    Registramos los cambios realizados para trazabilidad
    */
    IF v_cambio_compra OR v_cambio_avance THEN
        DBMS_OUTPUT.PUT_LINE('=====================================');
        DBMS_OUTPUT.PUT_LINE('AUDITORÍA DE CAMBIOS EN CUPOS');
        DBMS_OUTPUT.PUT_LINE('=====================================');
        DBMS_OUTPUT.PUT_LINE('Tarjeta: ' || :NEW.NRO_TARJETA);
        DBMS_OUTPUT.PUT_LINE('Cliente (RUT): ' || :NEW.NUMRUN);
        DBMS_OUTPUT.PUT_LINE('Fecha: ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));
        DBMS_OUTPUT.PUT_LINE('-------------------------------------');
        
        IF v_cambio_compra THEN
            DBMS_OUTPUT.PUT_LINE('CUPO DE COMPRA:');
            DBMS_OUTPUT.PUT_LINE('  Tipo de cambio: ' || v_tipo_cambio_compra);
            DBMS_OUTPUT.PUT_LINE('  Valor anterior: $' || TO_CHAR(:OLD.CUPO_COMPRA, '999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Valor nuevo: $' || TO_CHAR(:NEW.CUPO_COMPRA, '999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Diferencia: $' || TO_CHAR(ABS(v_diferencia_compra), '999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Cupo disponible actual: $' || TO_CHAR(:NEW.CUPO_DISP_COMPRA, '999,999,999'));
        END IF;
        
        IF v_cambio_avance THEN
            DBMS_OUTPUT.PUT_LINE('CUPO DE SUPER AVANCE:');
            DBMS_OUTPUT.PUT_LINE('  Tipo de cambio: ' || v_tipo_cambio_avance);
            DBMS_OUTPUT.PUT_LINE('  Valor anterior: $' || TO_CHAR(:OLD.CUPO_SUPER_AVANCE, '999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Valor nuevo: $' || TO_CHAR(:NEW.CUPO_SUPER_AVANCE, '999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Diferencia: $' || TO_CHAR(ABS(v_diferencia_avance), '999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Cupo disponible actual: $' || TO_CHAR(:NEW.CUPO_DISP_SP_AVANCE, '999,999,999'));
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('=====================================');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        -- Capturamos cualquier error no manejado
        DBMS_OUTPUT.PUT_LINE('ERROR en trigger TRG_AUDITAR_CAMBIOS_CUPOS:');
        DBMS_OUTPUT.PUT_LINE('Código: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Mensaje: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Tarjeta: ' || :NEW.NRO_TARJETA);
        RAISE; -- Re-lanzamos el error para que la transacción falle
        
END TRG_AUDITAR_CAMBIOS_CUPOS;
/

SHOW ERRORS;

/*******************************************************************************
 * EJEMPLOS DE USO:
 * 
 * -- Incrementar el cupo de compra (válido)
 * UPDATE TARJETA_CLIENTE 
 * SET CUPO_COMPRA = 2000000 
 * WHERE NRO_TARJETA = 12345;
 * 
 * -- Intentar establecer un cupo negativo (error controlado)
 * UPDATE TARJETA_CLIENTE 
 * SET CUPO_COMPRA = -100000 
 * WHERE NRO_TARJETA = 12345;
 * 
 * -- Intentar reducir el cupo por debajo del disponible (error controlado)
 * UPDATE TARJETA_CLIENTE 
 * SET CUPO_COMPRA = 500000 
 * WHERE NRO_TARJETA = 12345 
 * AND CUPO_DISP_COMPRA > 500000;
 ******************************************************************************/

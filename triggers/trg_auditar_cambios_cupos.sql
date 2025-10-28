/*******************************************************************************
 * TRIGGER: TRG_AUDITAR_CAMBIOS_CUPOS
 * ... (descripción igual) ...
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
    CORRECCIÓN: Se usa NVL para manejar correctamente los valores NULL.
    Un cupo NULL no es lo mismo que un cupo 0. Usamos -1 como valor
    imposible para comparar de forma segura.
    */
    IF NVL(:NEW.CUPO_COMPRA, -1) != NVL(:OLD.CUPO_COMPRA, -1) THEN
        v_cambio_compra := TRUE;
        v_diferencia_compra := NVL(:NEW.CUPO_COMPRA, 0) - NVL(:OLD.CUPO_COMPRA, 0);
        
        IF v_diferencia_compra > 0 THEN
            v_tipo_cambio_compra := 'INCREMENTO';
        ELSE
            v_tipo_cambio_compra := 'REDUCCIÓN';
        END IF;
    END IF;
    
    IF NVL(:NEW.CUPO_SUPER_AVANCE, -1) != NVL(:OLD.CUPO_SUPER_AVANCE, -1) THEN
        v_cambio_avance := TRUE;
        v_diferencia_avance := NVL(:NEW.CUPO_SUPER_AVANCE, 0) - NVL(:OLD.CUPO_SUPER_AVANCE, 0);
        
        IF v_diferencia_avance > 0 THEN
            v_tipo_cambio_avance := 'INCREMENTO';
        ELSE
            v_tipo_cambio_avance := 'REDUCCIÓN';
        END IF;
    END IF;
    
    /*
    PASO 2: VALIDACIONES DE NEGOCIO
    */
    
    -- Validación 1: Los cupos no pueden ser negativos (un cupo NULL se permite)
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
    Si se detectó un cambio, actualizamos la fecha de modificación.
    Esto requiere que la tabla TARJETA_CLIENTE tenga una columna
    llamada FECHA_MODIFICACION (o similar).
    */
    IF v_cambio_compra OR v_cambio_avance THEN

        NULL; 
    END IF;
    
    /*
    PASO 4: MOSTRAR INFORMACIÓN DE AUDITORÍA
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
            DBMS_OUTPUT.PUT_LINE('  Valor anterior: $' || TO_CHAR(:OLD.CUPO_COMPRA, 'FM999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Valor nuevo: $' || TO_CHAR(:NEW.CUPO_COMPRA, 'FM999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Diferencia: $' || TO_CHAR(ABS(v_diferencia_compra), 'FM999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Cupo disponible actual: $' || TO_CHAR(:NEW.CUPO_DISP_COMPRA, 'FM999,999,999'));
        END IF;
        
        IF v_cambio_avance THEN
            DBMS_OUTPUT.PUT_LINE('CUPO DE SUPER AVANCE:');
            DBMS_OUTPUT.PUT_LINE('  Tipo de cambio: ' || v_tipo_cambio_avance);
            DBMS_OUTPUT.PUT_LINE('  Valor anterior: $' || TO_CHAR(:OLD.CUPO_SUPER_AVANCE, 'FM999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Valor nuevo: $' || TO_CHAR(:NEW.CUPO_SUPER_AVANCE, 'FM999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Diferencia: $' || TO_CHAR(ABS(v_diferencia_avance), 'FM999,999,999'));
            DBMS_OUTPUT.PUT_LINE('  Cupo disponible actual: $' || TO_CHAR(:NEW.CUPO_DISP_SP_AVANCE, 'FM999,999,999'));
        END IF;
        
        DBMS_OUTPUT.PUT_LINE('=====================================');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en trigger TRG_AUDITAR_CAMBIOS_CUPOS:');
        DBMS_OUTPUT.PUT_LINE('Código: ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('Mensaje: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Tarjeta: ' || :NEW.NRO_TARJETA);
        RAISE; 
        
END TRG_AUDITAR_CAMBIOS_CUPOS;
/

SHOW ERRORS;
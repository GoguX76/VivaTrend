CREATE OR REPLACE TRIGGER TRG_ACTUALIZAR_CUPOS_PAGO
    AFTER INSERT ON PAGO_MENSUAL_TARJETA_CLIENTE
    FOR EACH ROW
DECLARE
    -- Variables locales para cálculos
    v_incremento_compra NUMBER;        -- Cuánto aumentar el cupo de compra
    v_incremento_avance NUMBER;        -- Cuánto aumentar el cupo de super avance
    v_cupo_max_compra NUMBER;          -- Cupo máximo permitido para compras
    v_cupo_max_avance NUMBER;          -- Cupo máximo permitido para avances
    v_cupo_actual_compra NUMBER;       -- Cupo disponible actual para compras
    v_cupo_actual_avance NUMBER;       -- Cupo disponible actual para avances
    
BEGIN
    /*
    PASO 1: CALCULAR LOS INCREMENTOS
    Dividimos el monto pagado entre compras (70%) y super avance (30%)
    */
    v_incremento_compra := :NEW.MONTO_PAGADO * 0.70;  -- 70% para compras
    v_incremento_avance := :NEW.MONTO_PAGADO * 0.30;  -- 30% para super avance
    
    /*
    PASO 2: OBTENER LOS CUPOS ACTUALES DE LA TARJETA
    Consultamos la tabla TARJETA_CLIENTE para conocer los límites y cupos actuales
    */
    SELECT 
        CUPO_COMPRA,              -- Límite máximo para compras
        CUPO_SUPER_AVANCE,        -- Límite máximo para super avance  
        CUPO_DISP_COMPRA,         -- Cupo actualmente disponible para compras
        CUPO_DISP_SP_AVANCE       -- Cupo actualmente disponible para super avance
    INTO 
        v_cupo_max_compra,
        v_cupo_max_avance,
        v_cupo_actual_compra,
        v_cupo_actual_avance
    FROM TARJETA_CLIENTE
    WHERE NRO_TARJETA = :NEW.NRO_TARJETA;
    
    /*
    PASO 3: CALCULAR LOS NUEVOS CUPOS DISPONIBLES
    Sumamos los incrementos pero sin exceder los límites máximos
    La función LEAST() nos asegura que no superemos el cupo máximo
    */
    v_cupo_actual_compra := LEAST(
        v_cupo_actual_compra + v_incremento_compra,  -- Nuevo cupo calculado
        v_cupo_max_compra                            -- Límite máximo
    );
    
    v_cupo_actual_avance := LEAST(
        v_cupo_actual_avance + v_incremento_avance,  -- Nuevo cupo calculado  
        v_cupo_max_avance                            -- Límite máximo
    );
    
    /*
    PASO 4: ACTUALIZAR LA TARJETA CON LOS NUEVOS CUPOS
    */
    UPDATE TARJETA_CLIENTE 
    SET 
        CUPO_DISP_COMPRA = v_cupo_actual_compra,
        CUPO_DISP_SP_AVANCE = v_cupo_actual_avance
    WHERE NRO_TARJETA = :NEW.NRO_TARJETA;
    
    /*
    PASO 5: REGISTRAR LA ACCIÓN EN LA SALIDA (OPCIONAL)
    Esto es útil para debugging y verificar que el trigger funciona
    */
    DBMS_OUTPUT.PUT_LINE('TRIGGER EJECUTADO:');
    DBMS_OUTPUT.PUT_LINE('- Tarjeta: ' || :NEW.NRO_TARJETA);
    DBMS_OUTPUT.PUT_LINE('- Monto pagado: $' || TO_CHAR(:NEW.MONTO_PAGADO, '999,999,999'));
    DBMS_OUTPUT.PUT_LINE('- Cupo compra incrementado en: $' || TO_CHAR(v_incremento_compra, '999,999,999'));
    DBMS_OUTPUT.PUT_LINE('- Cupo avance incrementado en: $' || TO_CHAR(v_incremento_avance, '999,999,999'));
    DBMS_OUTPUT.PUT_LINE('- Nuevo cupo disponible compra: $' || TO_CHAR(v_cupo_actual_compra, '999,999,999'));
    DBMS_OUTPUT.PUT_LINE('- Nuevo cupo disponible avance: $' || TO_CHAR(v_cupo_actual_avance, '999,999,999'));
    DBMS_OUTPUT.PUT_LINE('=====================================');

EXCEPTION
    /*
    MANEJO DE ERRORES:
    Si algo sale mal, capturamos el error y lo mostramos
    */
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: No se encontró la tarjeta ' || :NEW.NRO_TARJETA);
        RAISE; -- Re-lanzamos el error para que la transacción falle
        
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR en trigger TRG_ACTUALIZAR_CUPOS_PAGO: ' || SQLERRM);
        RAISE; -- Re-lanzamos el error para que la transacción falle
        
END TRG_ACTUALIZAR_CUPOS_PAGO;
/
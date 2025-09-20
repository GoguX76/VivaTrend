CREATE OR REPLACE PROCEDURE registrar_pago(
    p_numrun IN NUMBER,
    p_nro_tarjeta IN OUT NUMBER,
    p_cod_forma_pago IN OUT NUMBER,
    p_monto IN NUMBER,
    p_fecha_pago IN DATE
) AS
    v_anno_mes_pago VARCHAR(6);
    v_fecha_vencimiento_pago DATE;
    v_existe NUMBER := 0;
BEGIN

    IF p_nro_tarjeta IS NULL or p_nro_tarjeta = 0 THEN
        p_nro_tarjeta := SEQ_TARJETA_CLIENTE.NEXTVAL;
    END IF;

    SELECT COUNT(*) INTO v_existe
    FROM TARJETA_CLIENTE
    WHERE NRO_TARJETA = p_nro_tarjeta;

    IF v_existe = 0 THEN
        INSERT INTO TARJETA_CLIENTE(
            NRO_TARJETA, NUMRUN, FECHA_SOLIC_TARJETA, DIA_PAGO_MENSUAL,
            CUPO_COMPRA, CUPO_SUPER_AVANCE, CUPO_DISP_COMPRA, CUPO_DISP_SP_AVANCE, ID_ETARJETA
        ) VALUES (
            p_nro_tarjeta, p_numrun, SYSDATE, 1, 1000000, 500000, 1000000, 500000, 1
        );
    END IF;

    IF p_cod_forma_pago IS NULL OR p_cod_forma_pago NOT BETWEEN 1 AND 3 THEN
        p_cod_forma_pago := TRUNC(DBMS_RANDOM.VALUE(1,4));
    END IF;

    v_anno_mes_pago := TO_CHAR(p_fecha_pago, 'YYYYMM');
    v_fecha_vencimiento_pago := ADD_MONTHS(p_fecha_pago, 5);

    INSERT INTO PAGO_MENSUAL_TARJETA_CLIENTE(NRO_SECUENCIA_PAGO, NRO_TARJETA, COD_FORMA_PAGO, MONTO_PAGADO, FECHA_PAGO, ANNO_MES_PAGO, FECHA_VENCIMIENTO)
    VALUES(SEQ_PAGO_MENSUAL.NEXTVAL, p_nro_tarjeta, p_cod_forma_pago, p_monto, p_fecha_pago, v_anno_mes_pago, v_fecha_vencimiento_pago);

    DBMS_OUTPUT.PUT_LINE('El pago ha sido registrado con éxito');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error al registrar el pago ' || SQLERRM);

END;
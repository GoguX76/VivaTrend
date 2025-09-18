CREATE OR REPLACE PROCEDURE registrar_pago(
    p_numrun IN NUMBER,
    p_nro_tarjeta IN NUMBER,
    p_cod_forma_pago IN NUMBER,
    p_monto IN NUMBER,
    p_fecha_pago IN DATE
) AS
    v_anno_mes_pago VARCHAR(6);
    v_fecha_vencimiento_pago DATE;
BEGIN
    v_anno_mes_pago := TO_CHAR(p_fecha_pago, 'YYYYMM');
    v_fecha_vencimiento_pago := ADD_MONTHS(p_fecha_pago, 5);
    INSERT INTO PAGO_MENSUAL_TARJETA_CLIENTE(NRO_SECUENCIA_PAGO, NRO_TARJETA, COD_FORMA_PAGO, MONTO_PAGADO, FECHA_PAGO, ANNO_MES_PAGO, FECHA_VENCIMIENTO)
    VALUES(SEQ_PAGO_MENSUAL.NEXTVAL, p_nro_tarjeta, p_cod_forma_pago, p_monto, p_fecha_pago, v_anno_mes_pago, v_fecha_vencimiento_pago);
END;
DECLARE
    v_numrun NUMBER;
    v_nro_tarjeta NUMBER;
    v_cod_forma_pago NUMBER;
    v_monto NUMBER;
BEGIN
    
    SELECT NUMRUN INTO v_numrun FROM CLIENTE
    WHERE ROWNUM = 1;

    v_cod_forma_pago := NULL;
    v_monto := TRUNC(DBMS_RANDOM.VALUE(10000, 100001));

    registrar_pago(
        v_numrun,
        v_nro_tarjeta,
        v_cod_forma_pago,
        v_monto,
        SYSDATE
    );

    DBMS_OUTPUT.PUT_LINE('NRO_TARJETA generado: ' || v_nro_tarjeta);

END;
/
COMMIT;
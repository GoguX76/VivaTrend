-- RECORD guarda un VARRAY con hasta 3 métodos de pago en cado de ser usado, 
-- El VARRAY tiene sentido cuando quieres guardar varios valores para un mismo campo

DECLARE
    -- VARRAY para hasta 3 formas de pago más usadas
    TYPE formas_pago_array IS VARRAY(3) OF VARCHAR2(50);

    -- RECORD para los datos del cliente
    TYPE cliente_rec_type IS RECORD (
        RUT_CLIENTE         VARCHAR2(20),
        NOMBRE_CLIENTE      VARCHAR2(100),
        FECHA_NAC_CLIENTE   VARCHAR2(40),
        FECHA_INS_CLIENTE   VARCHAR2(40),
        CORREO_CLIENTE      VARCHAR2(100),
        FONO_CLIENTE        VARCHAR2(20),
        FORMAS_PAGO_TOP     formas_pago_array,
        CANT_PAGOS          NUMBER,
        ULTIMO_PAGO         DATE
    );

    cliente_rec cliente_rec_type;

    CURSOR cliente_cur IS
        SELECT
            TO_CHAR(CLI.NUMRUN, '09G999G999') || '-' || UPPER(DVRUN) AS RUT_CLIENTE,
            INITCAP(PNOMBRE || ' ' || SNOMBRE || ' ' || APPATERNO || ' ' || APMATERNO) AS NOMBRE_CLIENTE,
            TO_CHAR(FECHA_NACIMIENTO, 'DD "de" Month "de" YYYY', 'NLS_DATE_LANGUAGE=SPANISH') AS FECHA_NAC_CLIENTE,
            TO_CHAR(FECHA_INSCRIPCION, 'DD "de" Month "de" YYYY', 'NLS_DATE_LANGUAGE=SPANISH') AS FECHA_INS_CLIENTE,
            NVL(CORREO, 'Sin Correo') AS CORREO_CLIENTE,
            NVL(TO_CHAR(FONO_CONTACTO), 'Sin Fono Contacto') AS FONO_CLIENTE,
            COUNT(*) AS CANT_PAGOS,
            MAX(PAGCLI.FECHA_PAGO) AS ULTIMO_PAGO,
            CLI.NUMRUN
        FROM CLIENTE CLI
        LEFT JOIN TARJETA_CLIENTE TARCLI ON CLI.NUMRUN = TARCLI.NUMRUN
        LEFT JOIN PAGO_MENSUAL_TARJETA_CLIENTE PAGCLI ON TARCLI.NRO_TARJETA = PAGCLI.NRO_TARJETA
        LEFT JOIN FORMA_PAGO FORPAG ON PAGCLI.COD_FORMA_PAGO = FORPAG.COD_FORMA_PAGO
        GROUP BY
            CLI.NUMRUN, DVRUN, PNOMBRE, SNOMBRE, APPATERNO, APMATERNO, FECHA_NACIMIENTO,
            FECHA_INSCRIPCION, CORREO, FONO_CONTACTO;

BEGIN
    FOR cliente IN cliente_cur LOOP
        -- Inicializamos el VARRAY vacío
        cliente_rec.FORMAS_PAGO_TOP := formas_pago_array();

        -- Cargamos los 3 métodos de pago más usados
        SELECT NOMBRE_FORMA_PAGO
        BULK COLLECT INTO cliente_rec.FORMAS_PAGO_TOP
        FROM (
            SELECT F.NOMBRE_FORMA_PAGO, COUNT(*) AS uso
            FROM CLIENTE C
            INNER JOIN TARJETA_CLIENTE T ON C.NUMRUN = T.NUMRUN
            INNER JOIN PAGO_MENSUAL_TARJETA_CLIENTE P ON T.NRO_TARJETA = P.NRO_TARJETA
            INNER JOIN FORMA_PAGO F ON P.COD_FORMA_PAGO = F.COD_FORMA_PAGO
            WHERE C.NUMRUN = cliente.NUMRUN
            GROUP BY F.NOMBRE_FORMA_PAGO
            ORDER BY uso DESC
        )
        WHERE ROWNUM <= 3;

        -- Asignamos los demás datos
        cliente_rec.RUT_CLIENTE := cliente.RUT_CLIENTE;
        cliente_rec.NOMBRE_CLIENTE := cliente.NOMBRE_CLIENTE;
        cliente_rec.FECHA_NAC_CLIENTE := cliente.FECHA_NAC_CLIENTE;
        cliente_rec.FECHA_INS_CLIENTE := cliente.FECHA_INS_CLIENTE;
        cliente_rec.CORREO_CLIENTE := cliente.CORREO_CLIENTE;
        cliente_rec.FONO_CLIENTE := cliente.FONO_CLIENTE;
        cliente_rec.CANT_PAGOS := cliente.CANT_PAGOS;
        cliente_rec.ULTIMO_PAGO := cliente.ULTIMO_PAGO;

        -- Imprimir resultados
        DBMS_OUTPUT.PUT_LINE('RUT: ' || cliente_rec.RUT_CLIENTE);
        DBMS_OUTPUT.PUT_LINE('Nombre: ' || cliente_rec.NOMBRE_CLIENTE);
        DBMS_OUTPUT.PUT_LINE('Métodos de pago más usados:');
        IF cliente_rec.FORMAS_PAGO_TOP.COUNT > 0 THEN
            FOR i IN 1 .. cliente_rec.FORMAS_PAGO_TOP.COUNT LOOP
                DBMS_OUTPUT.PUT_LINE('   - ' || cliente_rec.FORMAS_PAGO_TOP(i));
            END LOOP;
        ELSE
            DBMS_OUTPUT.PUT_LINE('   - Sin Datos');
        END IF;
        DBMS_OUTPUT.PUT_LINE('------------------------------------');
    END LOOP;
END;


/* RECORD guarda un VARRAY con hasta 3 métodos de pago en cado de ser usado, 
 El VARRAY tiene sentido cuando quieres guardar varios valores para un mismo campo ,

Bucle anidado:
El cursor padre recorre clientes.
Por cada cliente, el cursor hijo recorre sus pagos.

Top1 método de pago: se calcula solo si el cliente tiene pagos, evitando errores y simplificando la lógica.
 */
SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
-- VARRAY para almacenar el método de pago más usado (solo 1)
    TYPE formas_pago_array IS VARRAY(1) OF VARCHAR2(50);

    -- RECORD para guardar datos del cliente

    TYPE cliente_rec_type IS RECORD (
        RUT_CLIENTE       VARCHAR2(20),
        NOMBRE_CLIENTE    VARCHAR2(100),
        FECHA_NAC_CLIENTE DATE,
        FECHA_INS_CLIENTE DATE,
        CORREO_CLIENTE    VARCHAR2(100),
        FONO_CLIENTE      VARCHAR2(20),
        FORMAS_PAGO_TOP1  formas_pago_array,
        CANT_PAGOS        NUMBER,
        ULTIMO_PAGO       DATE
    );

    cliente_rec cliente_rec_type;

    -- Cursor padre: todos los clientes

    CURSOR c_clientes IS
        SELECT NUMRUN, PNOMBRE || ' ' || APPATERNO AS NOMBRE,
               FECHA_NACIMIENTO, FECHA_INSCRIPCION, CORREO, FONO_CONTACTO
        FROM CLIENTE;

    -- Cursor hijo: pagos por cliente (recibe NUMRUN)

    CURSOR c_pagos (p_numrun CLIENTE.NUMRUN%TYPE) IS
        SELECT F.NOMBRE_FORMA_PAGO, P.FECHA_PAGO
        FROM TARJETA_CLIENTE T
        JOIN PAGO_MENSUAL_TARJETA_CLIENTE P ON T.NRO_TARJETA = P.NRO_TARJETA
        JOIN FORMA_PAGO F ON P.COD_FORMA_PAGO = F.COD_FORMA_PAGO
        WHERE T.NUMRUN = p_numrun;

    v_top1_pago   VARCHAR2(50);
    v_cant_pagos  NUMBER;
    v_ultimo_pago DATE;

BEGIN
    FOR reg_cli IN c_clientes LOOP
        v_cant_pagos := 0;
        v_ultimo_pago := NULL;
        v_top1_pago := 'Sin Datos';

        -- Recorremos los pagos del cliente
        FOR reg_pag IN c_pagos(reg_cli.NUMRUN) LOOP
            v_cant_pagos := v_cant_pagos + 1;
            IF v_ultimo_pago IS NULL OR reg_pag.FECHA_PAGO > v_ultimo_pago THEN
                v_ultimo_pago := reg_pag.FECHA_PAGO;
            END IF;
        END LOOP;

        -- Solo procesar si tiene pagos
        IF v_cant_pagos > 0 THEN
            BEGIN
                SELECT NOMBRE_FORMA_PAGO
                INTO v_top1_pago
                FROM (
                    SELECT F.NOMBRE_FORMA_PAGO, COUNT(*) AS USO
                    FROM TARJETA_CLIENTE T
                    JOIN PAGO_MENSUAL_TARJETA_CLIENTE P ON T.NRO_TARJETA = P.NRO_TARJETA
                    JOIN FORMA_PAGO F ON P.COD_FORMA_PAGO = F.COD_FORMA_PAGO
                    WHERE T.NUMRUN = reg_cli.NUMRUN
                    GROUP BY F.NOMBRE_FORMA_PAGO
                    ORDER BY USO DESC
                )
                WHERE ROWNUM = 1;

            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_top1_pago := 'Sin datos';
            END;

            -- Llenamos el RECORD
            cliente_rec.RUT_CLIENTE := TO_CHAR(reg_cli.NUMRUN);
            cliente_rec.NOMBRE_CLIENTE := reg_cli.NOMBRE;
            cliente_rec.FECHA_NAC_CLIENTE := reg_cli.FECHA_NACIMIENTO;
            cliente_rec.FECHA_INS_CLIENTE := reg_cli.FECHA_INSCRIPCION;
            cliente_rec.CORREO_CLIENTE := reg_cli.CORREO;
            cliente_rec.FONO_CLIENTE := reg_cli.FONO_CONTACTO;
            cliente_rec.CANT_PAGOS := v_cant_pagos;
            cliente_rec.ULTIMO_PAGO := v_ultimo_pago;

            cliente_rec.FORMAS_PAGO_TOP1 := formas_pago_array();
            cliente_rec.FORMAS_PAGO_TOP1.EXTEND;
            cliente_rec.FORMAS_PAGO_TOP1(1) := v_top1_pago;

            -- Imprimir resultados
            DBMS_OUTPUT.PUT_LINE('RUT: ' || cliente_rec.RUT_CLIENTE);
            DBMS_OUTPUT.PUT_LINE('Nombre: ' || cliente_rec.NOMBRE_CLIENTE);
            DBMS_OUTPUT.PUT_LINE('Cantidad de pagos: ' || cliente_rec.CANT_PAGOS);
            DBMS_OUTPUT.PUT_LINE('Último pago: ' || TO_CHAR(cliente_rec.ULTIMO_PAGO,'DD/MM/YYYY'));
            DBMS_OUTPUT.PUT_LINE('Método de pago más usado: ' || cliente_rec.FORMAS_PAGO_TOP1(1));
            DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
        END IF;
    END LOOP;

EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: valor fuera de rango o conversión inválida.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;

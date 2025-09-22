-- Script de métodos de pago más usados por cliente
SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    TYPE formas_pago_array IS VARRAY(3) OF VARCHAR2(100);
    
    TYPE cliente_rec_type IS RECORD (
        RUT_CLIENTE       VARCHAR2(20),
        NOMBRE_CLIENTE    VARCHAR2(200),
        FECHA_NAC_CLIENTE DATE,
        FECHA_INS_CLIENTE DATE,
        CORREO_CLIENTE    VARCHAR2(200),
        FONO_CLIENTE      VARCHAR2(50),
        FORMAS_PAGO_TOP3  formas_pago_array,
        CANT_PAGOS        NUMBER,
        ULTIMO_PAGO       DATE
    );

    cliente_rec cliente_rec_type;

    CURSOR c_clientes IS
        SELECT NUMRUN, 
               TRIM(COALESCE(PNOMBRE, '') || CASE 
                   WHEN PNOMBRE IS NOT NULL AND APPATERNO IS NOT NULL THEN ' ' 
                   ELSE '' 
               END || COALESCE(APPATERNO, '')) AS NOMBRE,
               FECHA_NACIMIENTO, 
               FECHA_INSCRIPCION, 
               TRIM(CORREO) AS CORREO,
               TRIM(TO_CHAR(FONO_CONTACTO)) AS FONO_CONTACTO
        FROM CLIENTE
        WHERE NUMRUN IS NOT NULL
          AND NUMRUN > 0;

    CURSOR c_pagos (p_numrun CLIENTE.NUMRUN%TYPE) IS
        SELECT TRIM(F.NOMBRE_FORMA_PAGO) AS NOMBRE_FORMA_PAGO, P.FECHA_PAGO
        FROM TARJETA_CLIENTE T
        JOIN PAGO_MENSUAL_TARJETA_CLIENTE P ON T.NRO_TARJETA = P.NRO_TARJETA
        JOIN FORMA_PAGO F ON P.COD_FORMA_PAGO = F.COD_FORMA_PAGO
        WHERE T.NUMRUN = p_numrun
          AND P.FECHA_PAGO IS NOT NULL
          AND F.NOMBRE_FORMA_PAGO IS NOT NULL
          AND LENGTH(TRIM(F.NOMBRE_FORMA_PAGO)) > 0;

    -- Cursor para obtener top 3 métodos de pago por cliente
    CURSOR c_top_pagos (p_numrun CLIENTE.NUMRUN%TYPE) IS
        SELECT TRIM(FORMA_PAGO_NOMBRE) AS NOMBRE_FORMA_PAGO
        FROM (
            SELECT FP.NOMBRE_FORMA_PAGO AS FORMA_PAGO_NOMBRE, COUNT(*) AS USO
            FROM TARJETA_CLIENTE TC
            JOIN PAGO_MENSUAL_TARJETA_CLIENTE PMT ON TC.NRO_TARJETA = PMT.NRO_TARJETA
            JOIN FORMA_PAGO FP ON PMT.COD_FORMA_PAGO = FP.COD_FORMA_PAGO
            WHERE TC.NUMRUN = p_numrun
              AND FP.NOMBRE_FORMA_PAGO IS NOT NULL
              AND LENGTH(TRIM(FP.NOMBRE_FORMA_PAGO)) > 0
            GROUP BY FP.NOMBRE_FORMA_PAGO
            ORDER BY USO DESC
        )
        WHERE ROWNUM <= 3;

    v_top_pagos   formas_pago_array;
    v_cant_pagos  NUMBER := 0;
    v_ultimo_pago DATE;
    v_contador    NUMBER := 0;

BEGIN
    FOR reg_cli IN c_clientes LOOP
        BEGIN
            -- Validar que NUMRUN sea un número válido
            IF reg_cli.NUMRUN IS NULL OR reg_cli.NUMRUN <= 0 THEN
                CONTINUE;
            END IF;
            
            v_cant_pagos := 0;
            v_ultimo_pago := NULL;
            v_top_pagos := formas_pago_array();

            FOR reg_pag IN c_pagos(reg_cli.NUMRUN) LOOP
                v_cant_pagos := v_cant_pagos + 1;
                IF v_ultimo_pago IS NULL OR 
                   (reg_pag.FECHA_PAGO IS NOT NULL AND reg_pag.FECHA_PAGO > v_ultimo_pago) THEN
                    v_ultimo_pago := reg_pag.FECHA_PAGO;
                END IF;
            END LOOP;

            IF v_cant_pagos > 0 THEN
                -- Obtener top 3 métodos de pago usando el cursor separado
                v_contador := 0;
                FOR rec_top_pago IN c_top_pagos(reg_cli.NUMRUN) LOOP
                    v_contador := v_contador + 1;
                    v_top_pagos.EXTEND;
                    v_top_pagos(v_contador) := SUBSTR(rec_top_pago.NOMBRE_FORMA_PAGO, 1, 100);
                END LOOP;
                
                -- Llenar VARRAY con valores por defecto si tiene menos de 3
                WHILE v_top_pagos.COUNT < 3 LOOP
                    v_top_pagos.EXTEND;
                    v_top_pagos(v_top_pagos.COUNT) := 'Sin datos';
                END LOOP;

                -- Asignar al RECORD con validaciones de longitud
                cliente_rec.RUT_CLIENTE := SUBSTR(TRIM(TO_CHAR(reg_cli.NUMRUN)), 1, 20);
                cliente_rec.NOMBRE_CLIENTE := SUBSTR(NVL(TRIM(reg_cli.NOMBRE), 'Sin nombre'), 1, 200);
                cliente_rec.FECHA_NAC_CLIENTE := reg_cli.FECHA_NACIMIENTO;
                cliente_rec.FECHA_INS_CLIENTE := reg_cli.FECHA_INSCRIPCION;
                cliente_rec.CORREO_CLIENTE := SUBSTR(NVL(TRIM(reg_cli.CORREO), 'No disponible'), 1, 200);
                cliente_rec.FONO_CLIENTE := SUBSTR(NVL(TRIM(reg_cli.FONO_CONTACTO), 'No disponible'), 1, 50);
                cliente_rec.CANT_PAGOS := v_cant_pagos;
                cliente_rec.ULTIMO_PAGO := v_ultimo_pago;
                cliente_rec.FORMAS_PAGO_TOP3 := v_top_pagos;

                DBMS_OUTPUT.PUT_LINE('RUT: ' || cliente_rec.RUT_CLIENTE);
                DBMS_OUTPUT.PUT_LINE('Nombre: ' || cliente_rec.NOMBRE_CLIENTE);
                DBMS_OUTPUT.PUT_LINE('Cantidad de pagos: ' || TO_CHAR(cliente_rec.CANT_PAGOS));
                DBMS_OUTPUT.PUT_LINE('Último pago: ' || 
                    CASE 
                        WHEN cliente_rec.ULTIMO_PAGO IS NOT NULL THEN TO_CHAR(cliente_rec.ULTIMO_PAGO,'DD/MM/YYYY')
                        ELSE 'No disponible'
                    END);
                DBMS_OUTPUT.PUT_LINE('Top 3 métodos de pago:');
                FOR i IN 1..cliente_rec.FORMAS_PAGO_TOP3.COUNT LOOP
                    DBMS_OUTPUT.PUT_LINE('  ' || i || '. ' || cliente_rec.FORMAS_PAGO_TOP3(i));
                END LOOP;
                DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
            END IF;

        EXCEPTION
            WHEN VALUE_ERROR THEN
                DBMS_OUTPUT.PUT_LINE('Error de conversión con cliente RUT: ' || 
                    NVL(TO_CHAR(reg_cli.NUMRUN), 'NULL') || ' - Datos inválidos');
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error procesando cliente RUT: ' || 
                    NVL(TO_CHAR(reg_cli.NUMRUN), 'NULL') || ' - ' || SQLERRM);
        END;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('Proceso completado.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/
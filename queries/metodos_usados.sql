/* Versión simplificada sin RECORD ni VARRAY para evitar errores de conversión */
SET SERVEROUTPUT ON SIZE 1000000;

DECLARE
    -- Variables simples en lugar de RECORD
    v_rut_cliente       VARCHAR2(20);
    v_nombre_cliente    VARCHAR2(100);
    v_correo_cliente    VARCHAR2(100);
    v_fono_cliente      VARCHAR2(20);
    v_top1_pago         VARCHAR2(50);
    v_cant_pagos        NUMBER;
    v_ultimo_pago       DATE;
    v_fecha_nac         DATE;
    v_fecha_ins         DATE;
    
    -- Contadores para debug
    v_total_clientes    NUMBER := 0;
    v_clientes_con_pagos NUMBER := 0;
    v_errores           NUMBER := 0;

BEGIN
    DBMS_OUTPUT.PUT_LINE('=== INICIANDO PROCESO SIMPLIFICADO ===');
    
    -- Bucle principal simplificado
    FOR reg_cli IN (
        SELECT NUMRUN, 
               COALESCE(PNOMBRE, '') || 
               CASE WHEN PNOMBRE IS NOT NULL AND APPATERNO IS NOT NULL THEN ' ' ELSE '' END || 
               COALESCE(APPATERNO, '') AS NOMBRE,
               FECHA_NACIMIENTO, 
               FECHA_INSCRIPCION, 
               CORREO, 
               FONO_CONTACTO
        FROM CLIENTE
        WHERE NUMRUN IS NOT NULL
    ) LOOP
        BEGIN
            v_total_clientes := v_total_clientes + 1;
            
            -- Asignar valores básicos de forma segura
            BEGIN
                v_rut_cliente := TRIM(TO_CHAR(reg_cli.NUMRUN));
                v_nombre_cliente := SUBSTR(COALESCE(TRIM(reg_cli.NOMBRE), 'Sin nombre'), 1, 100);
                v_correo_cliente := SUBSTR(COALESCE(TRIM(reg_cli.CORREO), 'No disponible'), 1, 100);
                v_fono_cliente := SUBSTR(COALESCE(TRIM(reg_cli.FONO_CONTACTO), 'No disponible'), 1, 20);
                v_fecha_nac := reg_cli.FECHA_NACIMIENTO;
                v_fecha_ins := reg_cli.FECHA_INSCRIPCION;
            EXCEPTION
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error asignando datos básicos para cliente: ' || COALESCE(TO_CHAR(reg_cli.NUMRUN), 'NULL'));
                    v_errores := v_errores + 1;
                    CONTINUE;
            END;
            
            -- Inicializar variables de pago
            v_cant_pagos := 0;
            v_ultimo_pago := NULL;
            v_top1_pago := 'Sin pagos';

            -- Contar pagos de forma simple
            BEGIN
                SELECT COUNT(*), MAX(P.FECHA_PAGO)
                INTO v_cant_pagos, v_ultimo_pago
                FROM TARJETA_CLIENTE T
                JOIN PAGO_MENSUAL_TARJETA_CLIENTE P ON T.NRO_TARJETA = P.NRO_TARJETA
                WHERE T.NUMRUN = reg_cli.NUMRUN
                  AND P.FECHA_PAGO IS NOT NULL;
                  
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_cant_pagos := 0;
                    v_ultimo_pago := NULL;
                WHEN OTHERS THEN
                    DBMS_OUTPUT.PUT_LINE('Error contando pagos para cliente ' || v_rut_cliente || ': ' || SQLERRM);
                    v_cant_pagos := 0;
                    v_ultimo_pago := NULL;
                    v_errores := v_errores + 1;
            END;

            -- Solo buscar método más usado si tiene pagos
            IF v_cant_pagos > 0 THEN
                v_clientes_con_pagos := v_clientes_con_pagos + 1;
                
                BEGIN
                    SELECT SUBSTR(TRIM(forma_pago), 1, 50)
                    INTO v_top1_pago
                    FROM (
                        SELECT F.NOMBRE_FORMA_PAGO AS forma_pago, COUNT(*) AS cantidad
                        FROM TARJETA_CLIENTE T
                        JOIN PAGO_MENSUAL_TARJETA_CLIENTE P ON T.NRO_TARJETA = P.NRO_TARJETA
                        JOIN FORMA_PAGO F ON P.COD_FORMA_PAGO = F.COD_FORMA_PAGO
                        WHERE T.NUMRUN = reg_cli.NUMRUN
                          AND F.NOMBRE_FORMA_PAGO IS NOT NULL
                          AND LENGTH(TRIM(F.NOMBRE_FORMA_PAGO)) > 0
                        GROUP BY F.NOMBRE_FORMA_PAGO
                        ORDER BY cantidad DESC
                    )
                    WHERE ROWNUM = 1;
                    
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        v_top1_pago := 'Sin datos válidos';
                    WHEN OTHERS THEN
                        v_top1_pago := 'Error en consulta';
                        DBMS_OUTPUT.PUT_LINE('Error obteniendo método más usado para cliente ' || v_rut_cliente || ': ' || SQLERRM);
                        v_errores := v_errores + 1;
                END;
            END IF;

            -- Mostrar resultados solo si tiene pagos
            IF v_cant_pagos > 0 THEN
                BEGIN
                    DBMS_OUTPUT.PUT_LINE('RUT: ' || v_rut_cliente);
                    DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre_cliente);
                    DBMS_OUTPUT.PUT_LINE('Correo: ' || v_correo_cliente);
                    DBMS_OUTPUT.PUT_LINE('Teléfono: ' || v_fono_cliente);
                    DBMS_OUTPUT.PUT_LINE('Fecha nacimiento: ' || 
                        CASE WHEN v_fecha_nac IS NOT NULL THEN TO_CHAR(v_fecha_nac, 'DD/MM/YYYY') ELSE 'No disponible' END);
                    DBMS_OUTPUT.PUT_LINE('Fecha inscripción: ' || 
                        CASE WHEN v_fecha_ins IS NOT NULL THEN TO_CHAR(v_fecha_ins, 'DD/MM/YYYY') ELSE 'No disponible' END);
                    DBMS_OUTPUT.PUT_LINE('Cantidad de pagos: ' || TO_CHAR(v_cant_pagos));
                    DBMS_OUTPUT.PUT_LINE('Último pago: ' || 
                        CASE WHEN v_ultimo_pago IS NOT NULL THEN TO_CHAR(v_ultimo_pago, 'DD/MM/YYYY') ELSE 'No disponible' END);
                    DBMS_OUTPUT.PUT_LINE('Método de pago más usado: ' || v_top1_pago);
                    DBMS_OUTPUT.PUT_LINE('-----------------------------------------');
                EXCEPTION
                    WHEN OTHERS THEN
                        DBMS_OUTPUT.PUT_LINE('Error mostrando datos para cliente ' || v_rut_cliente || ': ' || SQLERRM);
                        v_errores := v_errores + 1;
                END;
            END IF;

        EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error general procesando cliente RUT: ' || 
                    COALESCE(TO_CHAR(reg_cli.NUMRUN), 'NULL') || ' - ' || SQLERRM);
                v_errores := v_errores + 1;
        END;
        
        -- Mostrar progreso cada 50 clientes
        IF MOD(v_total_clientes, 50) = 0 THEN
            DBMS_OUTPUT.PUT_LINE('*** Procesados ' || v_total_clientes || ' clientes, ' || 
                               v_clientes_con_pagos || ' con pagos, ' || v_errores || ' errores ***');
        END IF;
        
    END LOOP;

    -- Resumen final
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('=== RESUMEN FINAL ===');
    DBMS_OUTPUT.PUT_LINE('Total clientes procesados: ' || v_total_clientes);
    DBMS_OUTPUT.PUT_LINE('Clientes con pagos: ' || v_clientes_con_pagos);
    DBMS_OUTPUT.PUT_LINE('Clientes sin pagos: ' || (v_total_clientes - v_clientes_con_pagos));
    DBMS_OUTPUT.PUT_LINE('Total errores: ' || v_errores);
    DBMS_OUTPUT.PUT_LINE('Proceso completado exitosamente.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('ERROR CRÍTICO en el proceso principal: ' || SQLERRM);
        DBMS_OUTPUT.PUT_LINE('Clientes procesados hasta el error: ' || v_total_clientes);
        DBMS_OUTPUT.PUT_LINE('Errores acumulados: ' || v_errores);
END;
/
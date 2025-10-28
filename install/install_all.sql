/*******************************************************************************
 * SCRIPT DE INSTALACIÓN COMPLETA - SISTEMA VIVATREND
 * 
 * Este script instala todos los componentes del sistema en el orden correcto:
 * 1. Secuencias (SEQ_TARJETA_CLIENTE, SEQ_PAGO_MENSUAL)
 * 2. Package (PKG_VIVATREND_TARJETAS - tipos y constantes)
 * 3. Funciones standalone (2 funciones)
 * 4. Procedimientos standalone (2 procedimientos)
 * 5. Triggers (2 triggers)
 * 
 * Ejecutar como usuario con privilegios suficientes en Oracle
 * 
 * VERSIÓN: 2.0 - Actualizado con todos los componentes del proyecto
 * FECHA: 27 de Octubre 2025
 ******************************************************************************/

-- Configuración del entorno
SET SERVEROUTPUT ON SIZE UNLIMITED;
SET VERIFY OFF;
SET FEEDBACK ON;
SET ECHO OFF;

PROMPT
PROMPT ========================================
PROMPT   INSTALACIÓN SISTEMA VIVATREND
PROMPT   Versión 2.0
PROMPT   Fecha: 27/10/2025
PROMPT ========================================
PROMPT

-- 1. SECUENCIAS
PROMPT ========================================
PROMPT [1/5] Creando Secuencias...
PROMPT ========================================
PROMPT
PROMPT - Secuencia para números de tarjeta...
@@../sequences/seq_tarjeta_cliente.sql
PROMPT - Secuencia para números de pago...
@@../sequences/seq_pago_mensual.sql
PROMPT ✓ Secuencias creadas exitosamente
PROMPT

-- 2. PACKAGE (tipos y constantes)
PROMPT ========================================
PROMPT [2/5] Creando Package Principal...
PROMPT ========================================
PROMPT
PROMPT - Package PKG_VIVATREND_TARJETAS (tipos y constantes)...
@@../packages/pkg_vivatrend_tarjetas.sql
PROMPT ✓ Package creado exitosamente
PROMPT

-- 3. FUNCIONES STANDALONE
PROMPT ========================================
PROMPT [3/5] Creando Funciones...
PROMPT ========================================
PROMPT
PROMPT - Función calcular_estadisticas_periodo (con parámetros)...
@@../functions/calcular_estadisticas_periodo.sql
PROMPT - Función obtener_total_clientes (sin parámetros)...
@@../functions/obtener_total_clientes.sql
PROMPT ✓ Funciones creadas exitosamente
PROMPT

-- 4. PROCEDIMIENTOS STANDALONE
PROMPT ========================================
PROMPT [4/5] Creando Procedimientos...
PROMPT ========================================
PROMPT
PROMPT - Procedimiento generar_reporte_mensual (sin parámetros)...
@@../procedures/generar_reporte_mensual.sql
PROMPT - Procedimiento obtener_resumen_cliente (con parámetros)...
@@../procedures/obtener_resumen_cliente.sql
PROMPT ✓ Procedimientos creados exitosamente
PROMPT

-- 5. TRIGGERS
PROMPT ========================================
PROMPT [5/5] Creando Triggers...
PROMPT ========================================
PROMPT
PROMPT - Trigger TRG_ACTUALIZAR_CUPOS_PAGO (actualiza cupos después de pago)...
@@../triggers/trg_actualizar_cupos_pago.sql
PROMPT - Trigger TRG_AUDITAR_CAMBIOS_CUPOS (audita cambios en límites)...
@@../triggers/trg_auditar_cambios_cupos.sql
PROMPT ✓ Triggers creados exitosamente
PROMPT

PROMPT
PROMPT ========================================
PROMPT   INSTALACIÓN COMPLETADA
PROMPT ========================================
PROMPT
PROMPT Verificando objetos creados...
PROMPT

-- Verificación de objetos creados
SELECT 
    object_type AS "TIPO",
    object_name AS "NOMBRE",
    status AS "ESTADO",
    TO_CHAR(created, 'DD/MM/YYYY HH24:MI:SS') AS "FECHA CREACIÓN"
FROM user_objects
WHERE object_name IN (
    'SEQ_TARJETA_CLIENTE',
    'SEQ_PAGO_MENSUAL',
    'PKG_VIVATREND_TARJETAS',
    'CALCULAR_ESTADISTICAS_PERIODO',
    'OBTENER_TOTAL_CLIENTES',
    'GENERAR_REPORTE_MENSUAL',
    'OBTENER_RESUMEN_CLIENTE',
    'TRG_ACTUALIZAR_CUPOS_PAGO',
    'TRG_AUDITAR_CAMBIOS_CUPOS'
)
ORDER BY 
    CASE object_type
        WHEN 'SEQUENCE' THEN 1
        WHEN 'PACKAGE' THEN 2
        WHEN 'FUNCTION' THEN 3
        WHEN 'PROCEDURE' THEN 4
        WHEN 'TRIGGER' THEN 5
        ELSE 6
    END,
    object_name;

PROMPT
PROMPT ========================================
PROMPT   RESUMEN DE LA INSTALACIÓN
PROMPT ========================================
PROMPT
PROMPT Componentes instalados:
PROMPT   • 2 Secuencias
PROMPT   • 1 Package (con 4 tipos de datos)
PROMPT   • 2 Funciones
PROMPT   • 2 Procedimientos
PROMPT   • 2 Triggers
PROMPT
PROMPT Total: 9 objetos SQL
PROMPT
PROMPT ========================================
PROMPT   FIN DE LA INSTALACIÓN
PROMPT ========================================
PROMPT
PROMPT Para probar el sistema, puedes ejecutar:
PROMPT   - SELECT obtener_total_clientes() FROM DUAL;
PROMPT   - EXEC generar_reporte_mensual;
PROMPT

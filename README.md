# Sistema VivaTrend - Gestión de Tarjetas y Pagos

## 📁 Estructura del Proyecto

```
VivaTrend/
├── packages/
│   └── pkg_vivatrend_tarjetas.sql    # Package principal (tipos, constantes y código)
├── sequences/
│   ├── seq_pago_mensual.sql          # Secuencia para pagos
│   └── seq_tarjeta_cliente.sql       # Secuencia para tarjetas
├── triggers/
│   └── trg_actualizar_cupos_pago.sql # Trigger para actualizar cupos
├── install/
│   └── install_all.sql               # Script de instalación completo
└── README.md                         # Este archivo
```

## 🚀 Instalación

### Opción 1: Instalación Automática (Recomendado)
```sql
@install/install_all.sql
```

### Opción 2: Instalación Manual
1. Crear secuencias:
```sql
@sequences/seq_tarjeta_cliente.sql
@sequences/seq_pago_mensual.sql
```

2. Crear package:
```sql
@packages/pkg_vivatrend_tarjetas.sql
```

3. Crear trigger:
```sql
@triggers/trg_actualizar_cupos_pago.sql
```

## 📝 Uso del Sistema

### Ejemplo 1: Registrar un Pago
```sql
DECLARE
    v_rut NUMBER := 12345678;
    v_tarjeta NUMBER := NULL;
    v_forma_pago NUMBER := NULL;
    v_resultado VARCHAR2(500);
BEGIN
    PKG_VIVATREND_TARJETAS.registrar_pago(
        v_rut, v_tarjeta, v_forma_pago, 50000, SYSDATE, v_resultado
    );
    DBMS_OUTPUT.PUT_LINE(v_resultado);
END;
/
```

### Ejemplo 2: Generar Reporte Mensual
```sql
BEGIN
    PKG_VIVATREND_TARJETAS.generar_reporte_mensual;
END;
/
```

### Ejemplo 3: Usar Funciones en SQL
```sql
SELECT 
    NRO_TARJETA,
    PKG_VIVATREND_TARJETAS.calcular_cupo_total_disponible(NRO_TARJETA) as cupo_total
FROM TARJETA_CLIENTE;
```

### Ejemplo 4: Consultar Todos los Clientes (PIPELINED)
```sql
SELECT * 
FROM TABLE(PKG_VIVATREND_TARJETAS.obtener_todos_clientes_resumen())
ORDER BY monto_total DESC;
```

## 📊 Componentes del Sistema

### Package PKG_VIVATREND_TARJETAS

**Tipos de Datos:**
- `t_cliente_resumen`: Resumen de información de cliente
- `t_info_cupos`: Información detallada de cupos
- `t_estadisticas_pago`: Estadísticas de pagos
- `t_tabla_clientes`: Colección de clientes

**Constantes:**
- `C_PAGO_EFECTIVO = 1`
- `C_PAGO_CHEQUE = 2`
- `C_PAGO_TRANSFERENCIA = 3`
- `C_CUPO_DEFAULT_COMPRA = 1,000,000`
- `C_CUPO_DEFAULT_AVANCE = 500,000`

**Procedimientos:**
1. `registrar_pago` - Registra un pago con validaciones
2. `obtener_resumen_cliente` - Obtiene resumen de cliente
3. `generar_reporte_mensual` - Genera reporte automático
4. `procesar_pagos_masivos` - Procesa múltiples pagos
5. `actualizar_estadisticas` - Actualiza estadísticas del sistema

**Funciones:**
1. `calcular_cupo_total_disponible` - Calcula cupo total
2. `obtener_metodo_preferido` - Método de pago más usado
3. `validar_monto_pago` - Valida montos
4. `obtener_info_cupos` - Información de cupos
5. `calcular_promedio_pagos` - Promedio de pagos
6. `obtener_desc_forma_pago` - Descripción de forma de pago
7. `existe_tarjeta` - Verifica existencia
8. `obtener_todos_clientes_resumen` - Todos los clientes (PIPELINED)
9. `contar_pagos_periodo` - Cuenta pagos en período
10. `calcular_estadisticas_periodo` - Estadísticas de período
11. `obtener_total_clientes` - Total de clientes

### Trigger: TRG_ACTUALIZAR_CUPOS_PAGO
- **Tipo:** AFTER INSERT FOR EACH ROW
- **Tabla:** PAGO_MENSUAL_TARJETA_CLIENTE
- **Función:** Actualiza cupos automáticamente (70% compra, 30% avance)

## 🎯 Contexto de Negocio

VivaTrend es una empresa retail que ofrece tarjetas de crédito con:
- **Cupo de Compra**: Para compras en tiendas
- **Cupo de Super Avance**: Para retiros de efectivo
- **Sistema de Pagos**: Los pagos incrementan cupos (70% compra, 30% avance)
- **Métodos de Pago**: Efectivo, Cheque, Transferencia

## ✅ Requisitos Cumplidos

- ✅ Procedimientos con y sin parámetros
- ✅ Funciones con y sin parámetros
- ✅ Package con constructores públicos y privados
- ✅ Triggers a nivel de sentencia y filas
- ✅ Procesamiento de información masiva
- ✅ Usable en SQL y PL/SQL

## 📞 Información

- **Versión**: 2.0
- **Fecha**: Octubre 2025
- **Base de Datos**: Oracle 11g o superior

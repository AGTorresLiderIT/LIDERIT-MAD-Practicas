# Tarea de desarrollo PRUEBA-SDD-01 — Campo Observaciones internas en clientes (prueba)

Código ERPIT: pendiente · Código en el origen: PRUEBA-SDD-01
Cliente: CLIENTE DEMO · Fecha: 15/10/2026 · Proyecto: Prueba de la skill sdd-tarea · Consultor: Alejandro González
Origen: Tarea de prueba inventada (sin datos de clientes) · Riesgo: VERDE (campo de texto y visualización) · Estado: Borrador · Puntos a validar pendientes: 1 (0 bloqueantes)

## 1. Descripción funcional

### Contexto
Tarea de prueba para validar el paso a GitHub de la skill. El área comercial quiere anotar observaciones internas en la ficha del cliente.

### Situación actual
La ficha estándar de cliente no tiene un campo de observaciones internas.

### Alcance
1. **Observaciones internas**
   - RF-1.1 Nuevo campo de texto «Observaciones internas» en la ficha de cliente.
   - RF-1.2 El campo se ve también en la lista de clientes.

### Puntos a validar

**Para el cliente**

| # | Tipo | Punto | Bloquea | Responde | Estado / respuesta |
| --- | --- | --- | --- | --- | --- |
| P-1 | Pregunta | ¿Longitud máxima del texto? | No | Ventas | Pendiente |

## 2. Descripción desarrollo

Se extiende la tabla y las páginas estándar de cliente.

### 1. Observaciones internas
**Ubicación:** Tabla Customer (18), páginas Customer Card (21) y Customer List (22).
Se añade el campo en la pestaña General de la ficha y como columna en la lista.


### Alcance técnico
- TableExtension 50100 «Customer Ext_LDR»: campo Internal Notes_LDR (Text 250).
- PageExtension 50101 y 50102 sobre ficha y lista de clientes.

### Consideraciones
- Sin impacto en procesos estándar.

### Reparto de tareas
Al aprobar la tarea, cada fila se crea como sub-issue en GitHub.

| Tarea | Descripción | Depende de | Hecho cuando |
| --- | --- | --- | --- |
| T-01 | Campo y páginas | — | Compila y se ve en ficha y lista |

## 3. Documentación técnica del desarrollo realizado

_Pendiente del técnico._

## 4. Guion de pruebas funcional key-user

Prueba del consultor en sandbox.

### Parametrización previa

### Escenarios de prueba
| Prueba | Requisito | Escenario | Resultado esperado | OK |
| --- | --- | --- | --- | --- |
| A-1 | RF-1.1 | Escribir una observación en la ficha de un cliente | El texto se guarda | |
| A-2 | RF-1.2 | Abrir la lista de clientes | La columna muestra la observación | |

## Fuentes

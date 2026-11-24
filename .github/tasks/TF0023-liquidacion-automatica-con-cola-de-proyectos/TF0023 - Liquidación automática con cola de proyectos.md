# Tarea de desarrollo TF0023 — Liquidación automática con cola de proyectos

Código ERPIT: pendiente · Código en el origen: TF0023
Cliente: LiderIT · Fecha: 17/11/2026 · Proyecto: Formación – Bloque 5 (Eventos, registro y procesos) · Consultor: Alejandro González Torres
Origen: Tarea de formación TF0023 – Liquidación automática con cola de proyectos (19/10/2026), Bloque 5. Depende de TF0021. · Riesgo: ROJO (proceso desatendido en la cola de proyectos, Commit por vendedor, Codeunit.Run con gestión de errores y generación de liquidaciones sin intervención) · Estado: En desarrollo · Puntos a validar pendientes: 10 (5 bloqueantes)

## 1. Descripción funcional

### Contexto
Cierre del Bloque 5. Dirección quiere que la liquidación de comisiones de TF0021 se haga sola el día 1 de cada mes de madrugada, liquidando hasta el último día del mes anterior, sin que nadie lance el proceso.

### Situación actual
Tras TF0021 la liquidación se lanza a mano con el report «Settle Commissions_LDR», que muestra progreso y un mensaje final. La lógica de un vendedor ya está en la codeunit «Settle Salesperson Commission_LDR». No hay programación automática ni registro de ejecuciones.

### Alcance
1. **Reutilización de la liquidación por vendedor**
   - RF-1.1 La liquidación automática y el report manual de TF0021 liquidan cada vendedor con la misma codeunit, sin duplicar lógica.
   - RF-1.2 La liquidación de un vendedor no muestra mensajes, confirmaciones ni ventanas cuando no hay interfaz; el report manual sigue con su ventana de progreso y su mensaje final.
2. **Registro de ejecuciones**
   - RF-2.1 Cada ejecución automática deja una línea por vendedor procesado con identificador de ejecución, fecha y hora de inicio y fin, vendedor, estado (Correcto, Aviso o Error), liquidación generada, mensaje y usuario.
   - RF-2.2 El registro se consulta en una lista no editable, de la más reciente a la más antigua, con una acción para abrir la liquidación.
3. **Proceso automático de liquidación**
   - RF-3.1 El proceso liquida hasta el último día del mes anterior a la fecha de ejecución, menos los días indicados en los parámetros, y genera o no factura según los parámetros.
   - RF-3.2 Si falla la liquidación de un vendedor, queda en el registro con estado Error y el texto del error, y el resto de vendedores se liquida.
   - RF-3.3 Si se pide factura y el vendedor no tiene proveedor o su total es menor o igual que cero, se liquida sin factura (como el report manual de TF0021) y la línea queda con estado Aviso y el motivo.
   - RF-3.4 Si los parámetros están mal escritos, el proceso no liquida nada y la entrada de la cola queda en Error con un mensaje entendible.
   - RF-3.5 Ejecutar el proceso dos veces en el mismo mes, o a la vez que el report manual, no liquida dos veces las mismas comisiones.
4. **Programación de la tarea**
   - RF-4.1 Una acción «Programar liquidación automática» en la lista de liquidaciones crea, si no existe ya, la entrada recurrente de la cola (día 1 de cada mes a las 02:00, parámetros FACTURA=SI;DIAS=0) y la pone en marcha.

### Puntos a validar

**Internos (LiderIT)**

| # | Tipo | Punto | Bloquea | Responde | Estado / respuesta |
| --- | --- | --- | --- | --- | --- |
| P-1 | Supuesto | Fecha hasta con Today y no con WorkDate: la fecha de trabajo es un ajuste del usuario en su sesión (en «Ejecutar una vez (en primer plano)» sería la del usuario que lo lanza) y el proceso debe liquidar según la fecha real de ejecución. Fecha hasta = CalcDate('<-CM-1D>', Today) - DIAS. Cuestionar en P1 de sdd-implementar. | Sí | Programador (validación del consultor) | Pendiente |
| P-2 | Supuesto | Recurrencia con <CM+1D> y no con <1M>: al terminar cada ejecución la cola calcula la siguiente fecha desde la fecha real en que termina (CleanupAfterExecution pasa CurrentDateTime a CalcNextRunTimeForRecurringJob, que hace CalcDate sobre esa fecha). Si una ejecución se retrasa al día 2, <1M> desplazaría la serie al día 2 de los meses siguientes; <CM+1D> vuelve siempre al día 1. Cuestionar en P1. | Sí | Programador (validación del consultor) | Pendiente |
| P-3 | Supuesto | Doble ejecución en el mismo mes (decisión del revisor): basta con seleccionar solo movimientos no liquidados (Liquidated de TF0021) porque cada vendedor se confirma con su propio Commit; una segunda ejecución o un reintento de la cola solo encuentra lo que quedó pendiente (vendedores con Error). No se añade control por mes ni marca de «ejecución en curso»: la cola no ejecuta a la vez dos veces la misma entrada. La protección frente a ejecuciones simultáneas con el report está en P-8. Cuestionar en P1. | Sí | Programador (validación del consultor) | Pendiente |
| P-4 | Supuesto | Commit y Codeunit.Run (decisión del revisor, confirmada en Learn): Codeunit.Run con valor de retorno exige no tener transacción de escritura abierta. Orden: validar parámetros (sin escribir), Commit, y por cada vendedor: ClearLastError, Clear de la variable de la codeunit, pasar fecha y opción, if Run, insertar la línea del registro fuera del Run (así sobrevive al error) y Commit. La codeunit de TF0021 no hace Commit ni usa CommitBehavior. Cuestionar en P1. | Sí | Programador (validación del consultor) | Pendiente |
| P-5 | Supuesto | Parámetros: formato CLAVE=VALOR separado por «;», claves FACTURA (SI/NO) y DIAS (entero >= 0), sin distinguir mayúsculas. Si el campo está vacío se usan FACTURA=SI;DIAS=0. Clave desconocida, valor no válido o clave repetida: error antes de procesar ningún vendedor. Cuestionar en P1. | No | Programador (validación del consultor) | Pendiente |
| P-6 | Supuesto | Avisos alineados con TF0021 (decisión del revisor): el proceso no detecta por su cuenta los casos sin proveedor o total <= 0, porque duplicaría la lógica de la codeunit y daría un resultado distinto al del report manual. La codeunit de TF0021 liquida sin factura y devuelve el motivo del aviso; el proceso lo registra como Aviso con la liquidación. Con FACTURA=NO esos vendedores salen como Correcto. El consultor confirma que el automático debe liquidar estos casos igual que el manual (incluido un total negativo). | Sí | Consultor | Pendiente |
| P-7 | Supuesto | Permisos (decisión del revisor): la cola ejecuta la tarea con el usuario del campo «User ID» de la entrada, que es quien la programa (Job Queue Entry, SetDefaultValues). Ese usuario necesita «Commissions_LDR» (tabla de registro con RIMD, página y codeunit nuevas), permisos estándar para crear facturas de compra y para programar tareas en la cola; no se crea un conjunto aparte. Se documenta en la parametrización de pruebas. Cuestionar en P1. | No | Programador (validación del consultor) | Pendiente |
| P-8 | Supuesto | Concurrencia con el report manual (decisión del revisor): no se bloquea el report. La codeunit de TF0021 lee los movimientos pendientes del vendedor con bloqueo (LockTable o ReadIsolation UpdLock) dentro de su transacción y, si ya no queda ninguno, termina sin crear liquidación y devuelve el aviso «Sin comisiones pendientes». Si choca con el report, el que espera puede acabar en tiempo de bloqueo agotado: ese vendedor queda en Error y se liquida en el reintento o en la siguiente ejecución. Es un cambio sobre la codeunit de TF0021. Cuestionar en P1. | No | Programador (validación del consultor) | Pendiente |
| P-10 | Supuesto | Interfaz de «Settle Salesperson Commission_LDR» (alineada con TF0021, que es su dueña): SetParameters(UpToDate: Date; CreateInvoice: Boolean) antes de Run(Salesperson), y GetSettlementNo(): Code[20] y GetWarningText(): Text después. Si TF0021 la crea con otros nombres se usan los suyos; lo imprescindible es pasar fecha y opción antes de Run y leer liquidación y aviso después. | No | Programador | Pendiente |
| P-9 | Fuera de alcance | Avisos por correo o notificaciones de errores, limpieza automática del registro de ejecuciones, programación en varias empresas a la vez y edición de la entrada de la cola desde la acción (se hace en «Movs. cola proyectos»). | No | Consultor | Pendiente |

## 2. Descripción desarrollo

Se añade un proceso para la cola de proyectos que reutiliza la liquidación por vendedor de TF0021. Se realizarán las siguientes modificaciones:

### 1. Reutilización de la liquidación por vendedor
**Ubicación:** Codeunit «Settle Salesperson Commission_LDR» y report «Settle Commissions_LDR» (TF0021); tabla Salesperson/Purchaser (13).
La codeunit de un vendedor ya existe desde TF0021 (TableNo = Salesperson/Purchaser). No se mueve lógica: se comprueba que el report y el proceso nuevo la llaman igual, con la interfaz de P-10 (fecha hasta y opción de factura antes de Run; nº de liquidación y texto de aviso después).

La codeunit no debe usar Message, Confirm ni Dialog en ningún caso (no basta con GuiAllowed: «Ejecutar una vez (en primer plano)» corre con interfaz), ni Commit. La ventana de progreso y el mensaje final se quedan en el report, que cuenta los avisos con GetWarningText.

Se añade en la codeunit la lectura con bloqueo de los movimientos pendientes y la salida sin liquidación si ya no queda ninguno (P-8).

- Los cambios en la codeunit (interacción, bloqueo, GetWarningText) se anotan como cambio sobre TF0021.
- El report manual debe seguir funcionando igual (escenario A-2).

### 2. Registro de ejecuciones
**Ubicación:** Tabla y página nuevas «Commission Process Log_LDR»; tabla «Commission Settlement_LDR» (TF0021).
Tabla nueva con una línea por vendedor procesado. Todas las líneas de una ejecución comparten el mismo «Run ID». La página es una lista no editable ordenada por «Entry No.» descendente, con la acción «Open Settlement» que abre la liquidación indicada.

| Campo | Tipo | Comentario |
| --- | --- | --- |
| Entry No. | Integer | Clave primaria (AutoIncrement) |
| Run ID | Guid | Mismo valor para todas las líneas de una ejecución |
| Start Date-Time | DateTime | Inicio de la ejecución |
| End Date-Time | DateTime | Fin del proceso del vendedor |
| Salesperson Code | Code[20] | Relación con Salesperson/Purchaser; vacío en la línea «Sin comisiones pendientes» |
| Status | Enum «Commission Process Status_LDR» | Correcto (Success) / Aviso (Warning) / Error |
| Settlement No. | Code[20] | Liquidación generada, si la hay |
| Message | Text[250] | Texto del aviso o GetLastErrorText recortado a 250 |
| User ID | Code[50] | Usuario con el que corre la cola |


### 3. Proceso automático de liquidación
**Ubicación:** Tabla Job Queue Entry (472); codeunit nueva «Commission Settlement JQ_LDR»; codeunit «Commission Mgt._LDR» (TF0020).
Codeunit nueva con TableNo = Job Queue Entry. En OnRun lee y valida Rec."Parameter String" antes de escribir nada; si es incorrecto lanza Error y la cola deja la entrada en Error con ese texto. Calcula la fecha hasta = CalcDate('<-CM-1D>', Today) - DIAS (P-1).

Hace Commit y recorre los vendedores con comisiones no liquidadas hasta esa fecha (función nueva en «Commission Mgt._LDR», con SetLoadFields). Por cada uno: ClearLastError, Clear de la codeunit de TF0021, SetParameters e if Run(Salesperson). Si va bien registra Correcto con la liquidación, o Aviso con la liquidación y el texto de GetWarningText si lo hay; si falla, Error con GetLastErrorText recortado. La línea se inserta fuera del Run y después se hace Commit (P-4).

Sin Message, Confirm ni Dialog. Si no hay ningún vendedor pendiente, registra una única línea Aviso «Sin comisiones pendientes».

- Mensaje: “Error de parámetros: «The parameter string '%1' is not valid. Use FACTURA=SI|NO;DIAS=<number of days>.» (ESP="El parámetro '%1' no es válido. Use FACTURA=SI|NO;DIAS=<nº de días>.")”
- Mensaje: “Los avisos de vendedor sin proveedor y total <= 0 son los de la codeunit de TF0021 (GetWarningText); no se crean textos nuevos.”
- Mensaje: “Aviso: «No pending commissions up to %1.» (ESP="Sin comisiones pendientes hasta el %1.")”

### 4. Programación de la tarea
**Ubicación:** Página lista de «Commission Settlement_LDR» (TF0021); tabla Job Queue Entry (472); codeunit Job Queue - Enqueue (453); página Job Queue Entries (672).
Acción «Schedule Automatic Settlement» (ESP="Programar liquidación automática"). Si ya existe una entrada para la codeunit (FindJobQueueEntry), informa y no crea otra. Si no, crea la entrada con los valores de la tabla y la pone en marcha con Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry).

Orden de asignación: «Starting Time» y «Earliest Start Date/Time» antes de validar «Next Run Date Formula»; si la fecha de inicio está vacía, el OnValidate de la fórmula la calcula sobre la fecha actual (Job Queue Entry, campo 29).

| Campo de Job Queue Entry | Valor |
| --- | --- |
| Object Type to Run / Object ID to Run | Codeunit / «Commission Settlement JQ_LDR» |
| Description | «Automatic commission settlement» (Label, ESP="Liquidación automática de comisiones") |
| Recurring Job | Sí |
| Starting Time | 02:00 |
| Earliest Start Date/Time | CreateDateTime(CalcDate('<CM+1D>', Today), 020000T) |
| Next Run Date Formula | <CM+1D> (Validate, ver P-2) |
| Maximum No. of Attempts to Run / Rerun Delay (sec.) | 3 / 300: los reintentos son seguros (P-3) y cubren bloqueos con el report manual (P-8) |
| Parameter String | FACTURA=SI;DIAS=0 |

- Mensaje: “«The automatic settlement is already scheduled. You can review it in Job Queue Entries.» (ESP="La liquidación automática ya está programada. Puede revisarla en Movs. cola proyectos.")”
- Mensaje: “«The automatic settlement has been scheduled for %1.» (ESP="La liquidación automática se ha programado para el %1.")”

### Alcance técnico
- Table 50006 «Commission Process Log_LDR»: registro de ejecuciones del proceso automático
- Enum 50001 «Commission Process Status_LDR»: estado de cada línea del registro: Success, Warning, Error
- Page 50007 «Commission Process Log_LDR»: lista no editable del registro, descendente, con acción para abrir la liquidación
- Codeunit 50007 «Commission Settlement JQ_LDR»: codeunit de la cola (TableNo = Job Queue Entry): parámetros, recorrido de vendedores, Codeunit.Run, registro y Commit
- Codeunit 50000 «Commission Mgt._LDR»: existente (TF0020): se añade la selección de vendedores con comisiones pendientes hasta una fecha y la programación de la entrada de la cola
- Codeunit 50002 «Settle Salesperson Commission_LDR»: existente (TF0021): se reutiliza; se comprueba que no tenga interacción ni Commit y se añaden lectura con bloqueo y GetWarningText si TF0021 no los tiene
- Page 50003 «Commission Settlements_LDR»: existente (TF0021, «Commission Settlements» en su origen): acción «Schedule Automatic Settlement» y acceso al registro
- PermissionSet 50000 «Commissions_LDR»: existente (TF0020): se añaden la tabla, la página y la codeunit nuevas
- Codeunit 50008 «Commission Settlement JQ Test_LDR»: tests automáticos (app de test): parámetros, error de un vendedor, avisos y doble ejecución
- Sin suscripciones a eventos: se usan la tabla Job Queue Entry (472) y la codeunit Job Queue - Enqueue (453) del estándar.
- Textos en Labels con Comment = 'ESP="..."'; los errores del proceso, con Label y sin concatenar texto libre.
- Codeunit.Run con valor de retorno solo sin transacción de escritura abierta: Commit antes del primer vendedor y tras la línea de registro de cada uno.

### Consideraciones
- Depende de TF0021: tabla y lista de liquidaciones, report «Settle Commissions_LDR» y codeunit «Settle Salesperson Commission_LDR» (la crea TF0021; aquí solo se reutiliza). La «refactorización previa» del enunciado queda en verificar ese uso y GuiAllowed.
- Las decisiones de P-1 a P-5 (Today, <CM+1D>, doble ejecución, Commit y Codeunit.Run, parámetros) se resuelven en la tarea por decisión del consultor. En sdd-implementar el programador debe cuestionarlas en P1 antes de construir.
- Today en la cola usa la zona horaria de la sesión de la cola; a las 02:00 de España el día 1 sigue siendo día 1, pero conviene comprobarlo en el entorno.
- «Ejecutar una vez (en primer plano)» corre con interfaz (GuiAllowed verdadero): el proceso no debe mostrar nada aunque pueda.
- Comprobado en application 28 (bc-observatory): los campos de Job Queue Entry usados (6, 7, 8, 11, 16, 17, 26, 29, 30, 47) y FindJobQueueEntry existen en 28, 29 y 30.
- Reintentos y doble ejecución son seguros porque cada vendedor se confirma por separado y solo se seleccionan movimientos no liquidados; un fallo a mitad deja firme lo anterior y el resto se recoge en la siguiente ejecución.
- Repositorio de prácticas compartido: sin objetos previos en main, sin impacto sobre desarrollos instalados.

### Reparto de tareas
Al aprobar la tarea, cada fila se crea como sub-issue en GitHub.

| Tarea | Descripción | Depende de | Hecho cuando |
| --- | --- | --- | --- |
| T-01 | Revisar en P1 las decisiones P-1 a P-8 y la interfaz de P-10 con el consultor | TF0021 terminada | Plan P1 firmado |
| T-02 | Revisar interacción, Commit, bloqueo y aviso en la codeunit de liquidación de TF0021 | T-01 | Pasa A-2 |
| T-03 | Tabla, enum y página del registro de ejecuciones | T-01 | Compila; pasa A-3 |
| T-04 | Codeunit de la cola con parámetros, avisos, Codeunit.Run y Commit | T-02, T-03 | Pasan A-4 a A-9 y A-12 |
| T-05 | Acción de programación en la lista de liquidaciones | T-04 | Pasan A-10 y A-11 |
| T-06 | Permisos, traducciones es-ES y tests automáticos | T-05 | Tests en verde y XLIFF completo |
| T-07 | Documentación técnica de entrega (solución, gestión de errores y transacciones, capturas de código, de la cola y del registro, dudas) | T-06 | Documento entregado al consultor |

## 3. Documentación técnica del desarrollo realizado

- Issue y rama: https://github.com/AGTorresLiderIT/LIDERIT-MAD-Practicas/issues/51 · rama Feature/TF0023-liquidacion-automatica-con-cola-de-proyectos
- Rama: https://github.com/AGTorresLiderIT/LIDERIT-MAD-Practicas/tree/Feature/TF0023-liquidacion-automatica-con-cola-de-proyectos

La liquidación de comisiones de TF0021 se puede programar en la cola de proyectos para que se ejecute sola el día 1 de cada mes a las 02:00, liquidando hasta el último día del mes anterior. Cada ejecución deja un registro por vendedor (Correcto, Aviso o Error) y el error de un vendedor no impide liquidar a los demás.

### Objetos creados o modificados

| Tipo | Id | Nombre | Cambio |
| --- | --- | --- | --- |
| codeunit | 50007 | Commission Settlement JQ_LDR | Nueva codeunit de la cola: valida parámetros y configuración, liquida cada vendedor pendiente y lo registra. |
| enum | 50001 | Commission Process Status_LDR | Nuevo estado de cada línea del registro: Correcto, Aviso o Error. |
| table | 50006 | Commission Process Log_LDR | Nueva tabla del registro de ejecuciones, una línea por vendedor procesado. |
| page | 50007 | Commission Process Log_LDR | Nueva lista no editable del registro, la más reciente arriba, con la acción Abrir liquidación. |
| page | 50003 | Commission Settlements_LDR | Acciones Programar liquidación automática y Registro del proceso (objeto de TF0021). |
| codeunit | 50000 | Commission Mgt._LDR | Nuevas funciones para saber si un vendedor tiene comisiones pendientes y para crear la entrada de la cola (objeto de TF0020). |
| permissionset | 50000 | Commissions_LDR | Se añaden la tabla, la página y la codeunit nuevas (objeto de TF0020). |

### RF-1.1, RF-1.2 · 1. Reutilización de la liquidación por vendedor

No se ha movido ni copiado lógica: la codeunit 50002 «Salesp. Comm. Settlement_LDR» de TF0021 ya liquidaba un vendedor sin mensajes ni Commit, con SetParameters antes de Run y GetSettlementNo y GetWarningText después. El report manual 50000 y la codeunit nueva de la cola la llaman igual; TF0021 no se modifica.

La única diferencia es intencionada: el report usa Run sin if (todo o nada, el usuario ve el error) y la cola usa if Run (el error de un vendedor queda registrado y se sigue con el resto). El report mantiene su ventana de progreso y su mensaje final.

### RF-2.1, RF-2.2 · 2. Registro de ejecuciones

La tabla 50006 guarda una línea por vendedor procesado; todas las líneas de una ejecución comparten el mismo Id. ejecución. Si no hay nada pendiente se guarda una sola línea Aviso sin vendedor. El usuario es el de la entrada de la cola.

La página 50007 es de solo lectura, ordenada de la más reciente a la más antigua, con la acción Abrir liquidación. Se abre desde Registro del proceso en la lista de liquidaciones o desde el buscador. Sin impacto en datos existentes: tabla nueva.

| Campo | Id | Tipo dato | Comentario |
| --- | --- | --- | --- |
| Entry No. | 1 | Integer | Clave, autoincremental. |
| Run ID | 2 | Guid | Igual en todas las líneas de una ejecución. |
| Start Date-Time / End Date-Time | 3, 4 | DateTime | Inicio de la ejecución y fin del vendedor. |
| Salesperson Code | 5 | Code[20] | En blanco en la línea Sin comisiones pendientes. |
| Status | 6 | Enum 50001 | Correcto, Aviso o Error. |
| Settlement No. | 7 | Code[20] | Liquidación creada, si la hay. |
| Message | 8 | Text[250] | Texto del aviso o del error. |
| User ID | 9 | Code[50] | Usuario con el que corre la cola. |

[Captura: Registro del proceso con una ejecución: A en Correcto, B y C en Aviso]

### RF-3.1, RF-3.2, RF-3.3, RF-3.4, RF-3.5 · 3. Proceso automático de liquidación

La codeunit 50007 (TableNo = Job Queue Entry) lee los parámetros FACTURA=SI|NO;DIAS=n (vacío equivale a FACTURA=SI;DIAS=0) y comprueba la configuración antes de escribir nada: serie de liquidaciones y, con factura, que la cuenta de comisiones sea auxiliar y admita Registro directo. Si algo falla, la entrada de la cola queda en Error con el mensaje y no se liquida a nadie. La comprobación de la cuenta se añadió tras ver en las pruebas que, sin Registro directo, fallaban uno a uno todos los vendedores con proveedor.

La fecha hasta es el último día del mes anterior a la fecha real (Today) menos DIAS: la fecha de trabajo es un ajuste de la sesión y no avanza sola (P-1).

Tras un Commit, recorre los vendedores con comisiones sin liquidar hasta esa fecha y llama a la codeunit de TF0021 con if Run. La línea del registro se inserta fuera del Run y se confirma con Commit por vendedor, así el error de uno no deshace lo de los demás (P-4).

Los avisos (sin proveedor, proveedor bloqueado o total <= 0) son los de TF0021: se liquida sin factura y la línea queda en Aviso. Si al liquidar ya no queda nada, por ejemplo porque lo ha liquidado el report manual, la línea es Aviso «Sin comisiones pendientes».

No hay control de doble ejecución en el mes (P-3): solo se seleccionan comisiones no liquidadas y la codeunit de TF0021 las bloquea al leerlas, así que una segunda ejecución o un reintento solo recoge lo que quedó pendiente.

```al
ClearLastError();
Clear(SettleSalespersonCommission);
SettleSalespersonCommission.SetParameters(UpToDate, CreateInvoice);
if not SettleSalespersonCommission.Run(SalespersonPurchaser) then begin
    InsertLog(SalespersonCode, "Commission Process Status_LDR"::Error, '', GetLastErrorText());
    exit;
end;
```

### RF-4.1 · 4. Programación de la tarea

La acción Programar liquidación automática de la lista de liquidaciones llama a ScheduleAutomaticSettlement de la codeunit 50000. Si ya existe una entrada para la codeunit 50007 (FindJobQueueEntry), avisa y no crea otra. Si no, la crea y la pone en marcha con la codeunit estándar 453 Job Queue - Enqueue.

La hora y la primera fecha se asignan antes de validar la fórmula: si la primera fecha estuviera vacía, la validación la calcularía desde la fecha y hora actuales. Se usa <CM+1D> y no <1M> porque la cola calcula la siguiente fecha desde el final real de la ejecución: con <1M>, un retraso al día 2 desplazaría la serie (P-2).

| Campo de Job Queue Entry | Valor |
| --- | --- |
| Object Type / ID to Run | Codeunit 50007 |
| Recurring Job / Next Run Date Formula | Sí / <CM+1D> |
| Starting Time / Earliest Start Date/Time | 02:00 / día 1 del mes siguiente a las 02:00 |
| Maximum No. of Attempts / Rerun Delay | 3 / 300 s |
| Parameter String | FACTURA=SI;DIAS=0 |

[Captura: Entrada de la cola creada por la acción, con la fórmula y los parámetros]

### Pruebas técnicas realizadas

**Prueba manual de los escenarios A-1 a A-11 en el sandbox**
- Con fecha real 24/11/2026 (fecha hasta 31/10/2026) se registraron comisiones del 15/10/2026 para tres vendedores: A con proveedor, B con proveedor bloqueado y C sin proveedor, y una del 05/11/2026 para A.
- Se programó la entrada (A-10) y al repetir la acción avisó de que ya existía (A-11).
- Con Ejecutar una vez (primer plano): sin datos de octubre dejó una sola línea Sin comisiones pendientes; después, A falló por la cuenta de comisiones sin Registro directo mientras B y C se liquidaban con Aviso (A-5, A-6) y la entrada terminó en Correcto. Corregida la cuenta, A se liquidó en Correcto por 10,00 € y la comisión de noviembre siguió pendiente (A-4).
- Una segunda ejecución no liquidó nada (A-9); con FACTURA=QUIZA y con DIAS=-3 la entrada terminó en Error sin líneas (A-8); con FACTURA=NO;DIAS=10 solo se liquidó hasta el 21/10/2026 y sin factura (A-7).
- Con la cuenta sin Registro directo y la comprobación nueva, la entrada terminó en Error sin liquidar ni registrar nada.
- El report manual mantuvo su progreso y su mensaje final (A-2); A-1 se revisó en el código. A-12 (report y cola a la vez) no se ha probado.
[Captura: Liquidaciones creadas por la cola con fecha hasta 31/10/2026]
[Captura: Error de la entrada de la cola por parámetro no válido]
[Captura: Movimientos de A con la comisión del 05/11/2026 pendiente]

### Para quien prueba
- Dónde está: en «Liquidaciones de comisiones», las acciones Programar liquidación automática y Registro del proceso; la entrada se ve y se ejecuta en «Movs. cola proyectos» (Ejecutar una vez, primer plano).
- Configuración previa: serie de liquidaciones; cuenta de comisiones auxiliar con Registro directo; vendedores con % de comisión (con 0 % no se generan comisiones) y, para la factura, proveedor en la ficha del vendedor.
- Datos de prueba: el proceso liquida hasta el último día del mes anterior a la fecha real, no a la fecha de trabajo; las facturas de prueba deben tener fecha de registro de ese mes o anterior.
- Las dos ventanas que salen al ejecutar en primer plano (confirmación y Estado: Correcto) son del estándar; el proceso no muestra ningún mensaje propio.


## 4. Guion de pruebas funcional key-user

Pruebas que valida el consultor en el sandbox de prácticas (CRONUS ES) con fecha real 17/11/2026, por lo que la fecha hasta por defecto es 31/10/2026.

### Parametrización previa
- TF0020 a TF0021 instaladas y configuradas (configuración de ventas, serie de liquidaciones).
- Vendedor A con proveedor y comisiones pendientes de 120,00 € y 80,00 € de octubre, y otra de 30,00 € del 05/11/2026.
- Vendedor B con proveedor bloqueado y comisión pendiente de 50,00 € de octubre.
- Vendedor C sin proveedor y comisión pendiente de 40,00 € de octubre.
- Vendedor D con proveedor y un abono que deja su comisión pendiente de octubre en -15,00 €.
- Sin otras entradas de la cola para la codeunit «Commission Settlement JQ_LDR».
- La entrada se programa con un usuario con «Commissions_LDR», permisos de compras para crear facturas y permisos de cola de proyectos.

### Escenarios de prueba
| Prueba | Requisito | Escenario | Resultado esperado | OK |
| --- | --- | --- | --- | --- |
| A-1 | RF-1.1 | Revisar con el programador el código del report y de la codeunit de la cola | Ambos llaman a «Settle Salesperson Commission_LDR»; no hay lógica de liquidación copiada |  |
| A-2 | RF-1.2 | Lanzar a mano el report de TF0021 para el vendedor A hasta 31/10/2026 | Ventana de progreso y mensaje final como en TF0021; liquidación de 200,00 € |  |
| A-3 | RF-2.1, RF-2.2 | Tras A-5, abrir el registro de ejecuciones y usar «Abrir liquidación» en la línea del vendedor A | Lista no editable, la ejecución más reciente arriba, todas sus líneas con el mismo Run ID y el usuario de la cola; se abre la liquidación de A |  |
| A-4 | RF-3.1 | Con Parameter String FACTURA=SI;DIAS=0, ejecutar la entrada con «Ejecutar una vez (en primer plano)» | Vendedor A liquidado por 200,00 € con factura; la comisión del 05/11/2026 (30,00 €) sigue pendiente; sin mensajes en pantalla |  |
| A-5 | RF-3.2 | La misma ejecución de A-4, con el proveedor del vendedor B bloqueado | Línea de B con estado Error y el texto del error de proveedor bloqueado; A liquidado igualmente; la entrada de la cola no queda en Error |  |
| A-6 | RF-3.3 | La misma ejecución de A-4 para los vendedores C y D | C liquidado por 40,00 € sin factura, con Aviso de que no tiene proveedor; D liquidado por -15,00 € sin factura, con Aviso de total no positivo (mismo resultado que el report manual) |  |
| A-7 | RF-3.1 | Deshacer la liquidación de A, cambiar a FACTURA=NO;DIAS=10 y ejecutar en primer plano | Solo se liquidan las comisiones de A hasta 21/10/2026, sin factura |  |
| A-8 | RF-3.4 | Poner Parameter String FACTURA=QUIZA;DIAS=0 (y después DIAS=-3) y ejecutar | La entrada queda en Error con el mensaje de parámetro no válido; no se crea ninguna liquidación ni línea en el registro |  |
| A-9 | RF-3.5 | Ejecutar dos veces seguidas la entrada con FACTURA=SI;DIAS=0 | La segunda no crea liquidaciones; solo aparece la línea Error de B si su proveedor sigue bloqueado |  |
| A-10 | RF-4.1 | En la lista de liquidaciones, pulsar «Programar liquidación automática» el 17/11/2026 y abrir «Movs. cola proyectos» | Entrada En espera para la codeunit, recurrente, fórmula <CM+1D>, hora 02:00, inicio 01/12/2026 02:00, 3 intentos y parámetros FACTURA=SI;DIAS=0 |  |
| A-11 | RF-4.1 | Pulsar de nuevo «Programar liquidación automática» | Mensaje de que ya está programada; sigue habiendo una sola entrada |  |
| A-12 | RF-3.5 | Con una comisión pendiente nueva del vendedor A, ejecutar a la vez el report manual para A y la entrada de la cola (en el test automático, con dos sesiones o simulando el bloqueo) | Solo uno de los dos liquida a A; el otro no crea liquidación (Aviso «Sin comisiones pendientes» o Error de bloqueo en el registro) |  |

## Anexo · Control de la implementación

**Firmas y revisión**

| Quién | Usuario | Fecha | Detalle |
| --- | --- | --- | --- |
| P1 | AlejandroGallego-LiderIT | 2026-11-24 | Se hará un proceso para que la liquidación de comisiones se haga una vez al mes, un día de madrugada, hasta el último día del mes anterior. Registro: tabla Commission Process Log con Entry No., Run ID, Start Date-Time, End Date-Time, Salesperson Code, Status (Correcto/Aviso/Error), Settlement No., Message (texto del error con GetLastErrorText o el aviso de GetWarningText) y User ID. Página lista no editable, ordenada de la más reciente a la más antigua, con una acción para abrir la liquidación. Proceso: codeunit de la cola Commission Settlement JQ con TableNo = Job Queue Entry. En OnRun lee Rec."Parameter String" con formato FACTURA=SI;DIAS=0 (DIAS es un entero >= 0 que se resta a la fecha hasta); si está mal escrito, o falta la serie de liquidaciones (o la cuenta con FACTURA=SI), da error y no se liquida nada. La fecha hasta es el último día del mes anterior a Today menos DIAS, sin WorkDate, porque la fecha de trabajo no cambia sola. Commit antes del primer vendedor. Por cada vendedor con comisiones pendientes: ClearLastError, if Codeunit.Run de la codeunit de liquidación de TF0021, y se registra Correcto, Aviso (sin proveedor, proveedor bloqueado o total <= 0: liquida sin factura, como el report manual) o Error, insertando la línea fuera del Run, y Commit después de cada vendedor para que un error no deshaga lo correcto. Si al liquidar ya no queda nada pendiente, o no hay ningún vendedor pendiente, se registra un Aviso «Sin comisiones pendientes». Sin Message, Confirm ni Dialog en el proceso. Programar: en la lista de liquidaciones, una acción que crea la entrada de la cola si no existe ya: Object Type to Run = Codeunit, Object ID to Run = la codeunit anterior, Recurring Job = sí, Next Run Date Formula = <CM+1D>, Earliest Start Date/Time = día 1 del mes siguiente a las 02:00, 3 intentos con 300 s entre ellos y Parameter String FACTURA=SI;DIAS=0; se pone en marcha con Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry). No se hace: ningún control extra de doble ejecución en el mes (un segundo intento solo encuentra lo no liquidado); no se cambia la lógica del report ni de la codeunit de TF0021 (la lógica ya se movió a la codeunit en TF0021); ni correos, ni limpieza del registro. Ejemplo: JR, con proveedor, tiene comisiones de 120 € y 80 € de octubre y de 30 € del 05/11/2026. Se ejecuta el 24/11/2026 con FACTURA=SI;DIAS=0: se liquida hasta el 31/10/2026, sale una liquidación de 200 € con factura de compra, los 30 € de noviembre siguen pendientes y en el registro aparece una línea de JR en estado Correcto con el nº de liquidación. Si se ejecuta otra vez, no se liquida nada y sale una línea Aviso «Sin comisiones pendientes». (Los puntos de qué falta, qué no se hace y el ejemplo se adoptaron de la propuesta de Claude a petición del programador.) |

**Trazabilidad requisito → cambio → prueba → evidencia**

| Requisito | Cambios | Escenarios | Evidencia |
| --- | --- | --- | --- |
| RF-1.1 | C-03 La codeunit de la cola llama a Salesp. Comm. Settlement_LDR (50002) igual que el report 50000 de TF0021 (SetParameters, Run, GetSettlementNo, GetWarningText); no se copia lógica de liquidación | A-1 | E-17 manual OK |
| RF-1.2 | — | A-2 | E-16 manual OK |
| RF-2.1 | C-01 Enum 50001 (Success/Warning/Error, Correcto/Aviso/Error) y tabla 50006 Commission Process Log_LDR con Entry No. autoincremental, Run ID, inicio y fin, vendedor, estado, nº liquidación, mensaje y usuario; permission set con tabledata RIMD | A-3 | E-01 al_compile OK; E-11 manual OK; E-12 manual OK |
| RF-2.2 | C-02 Página 50007 no editable ordenada por Entry No. descendente con acción Abrir liquidación; acción Registro del proceso en la lista de liquidaciones | A-3 | E-11 manual OK; E-12 manual OK |
| RF-3.1 | C-04 Codeunit 50007 con TableNo Job Queue Entry: fecha hasta CalcDate('<-CM-1D>', Today) - DIAS; FACTURA según parámetros; HasPendingCommissions en Commission Mgt para seleccionar vendedores con pendientes | A-4, A-7 | E-09 manual KO; E-10 manual OK; E-15 manual OK |
| RF-3.2 | C-05 Commit antes del primer vendedor; por vendedor ClearLastError, Clear, if Run; si falla, línea Error con GetLastErrorText insertada fuera del Run y Commit, y se sigue con el resto | A-5 | E-02 al_compile OK; E-07 manual OK |
| RF-3.3 | C-06 Si la codeunit de TF0021 devuelve aviso (sin proveedor, proveedor no válido o total <= 0, liquida sin factura) la línea queda Aviso con el texto y la liquidación | A-6 | E-08 manual OK |
| RF-3.4 | C-07 Parámetros FACTURA=SI/NO;DIAS=n validados antes de escribir (clave desconocida, valor no válido o repetida = Error); vacío = FACTURA=SI;DIAS=0; además se comprueba la configuración (serie y, con factura, cuenta) al principio (decisión de P1); C-11 CheckSetup: con FACTURA=SI la cuenta de comisiones debe existir, ser de tipo Auxiliar y tener Registro directo; si no, error antes de liquidar (decisión del programador tras el fallo de A en las pruebas) | A-8 | E-14 manual OK; E-18 al_compile OK; E-19 manual OK |
| RF-3.5 | C-08 Sin control extra (P-3): solo se seleccionan movimientos no liquidados y TF0021 bloquea con LockTable; si al liquidar ya no queda nada, Aviso Sin comisiones pendientes; sin vendedores pendientes, una línea Aviso | A-9, A-12 | E-06 manual OK; E-13 manual OK |
| RF-4.1 | C-09 Acción Programar liquidación automática en la lista de liquidaciones; ScheduleAutomaticSettlement en Commission Mgt: si FindJobQueueEntry la encuentra, avisa y no crea otra; si no, crea la entrada (Codeunit 50007, recurrente, Starting Time 02:00, Earliest Start día 1 del mes siguiente 02:00 antes de validar <CM+1D>, 3 intentos, 300 s, FACTURA=SI;DIAS=0) y la pone en marcha con Job Queue - Enqueue; C-10 XLIFF g.xlf regenerado y es-ES completado con los ESP de TF0023 | A-10, A-11 | E-03 al_compile OK; E-04 manual OK; E-05 manual OK |

## Fuentes
- Tarea de formación TF0023 (apartados/TF0023.md); reparto.md del Bloque 5 (dueños de objetos).
- BC 29 ES: Modules/System/JobQueue/JobQueueEntry.Table.al (campos 6, 7, 8, 11, 16, 17, 26, 29, 30, 47; OnValidate de Next Run Date Formula l. 305; SetDefaultValues l. 969, User ID; CleanupAfterExecution l. 1006; FindJobQueueEntry l. 1432); JobQueueDispatcher.Codeunit.al l. 329 (CalcDate de Next Run Date Formula); codeunit 453 Job Queue - Enqueue; página 672.
- bc-observatory: tabla 472 Job Queue Entry, campos y procedimientos (BC 28, 29 y 30).
- https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/codeunit/codeunit-run-method (con valor de retorno confirma al final; si hay transacción abierta hay que hacer Commit antes)
- https://learn.microsoft.com/dynamics365/business-central/admin-job-queues-schedule-tasks (recurrencia, Earliest Start, reintentos con Maximum No. of Attempts y Rerun Delay)
- Revisado con bc-code-intel (especialistas: sam-coder; find_bc_knowledge: eva-errors/codeunit-run-pattern). La respuesta fue genérica: las decisiones de transacciones se apoyan en Learn y en el código estándar.

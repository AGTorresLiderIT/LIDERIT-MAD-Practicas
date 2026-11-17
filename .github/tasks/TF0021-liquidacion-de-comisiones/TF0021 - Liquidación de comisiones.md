# Tarea de desarrollo TF0021 — Liquidación de comisiones

Código ERPIT: pendiente · Código en el origen: TF0021
Cliente: LiderIT · Fecha: 17/11/2026 · Proyecto: Formación – Bloque 5 (Eventos, registro y procesos) · Consultor: Alejandro González Torres
Origen: Tarea de formación TF0021 – Liquidación de comisiones (Bloque 5, 19/10/2026). Depende de TF0020. · Riesgo: ROJO (genera facturas de compra, modifica movimientos de comisión en lote y permite deshacer la liquidación) · Estado: En GitHub · Puntos a validar pendientes: 10 (1 bloqueantes)

## 1. Descripción funcional

### Contexto
Continuación de TF0020. Cada mes el responsable comercial liquida las comisiones pendientes de los vendedores hasta una fecha. Los vendedores son autónomos y facturan su comisión, por lo que la liquidación puede generar una factura de compra en borrador a su proveedor.

### Situación actual
Tras TF0020, al registrar facturas y abonos de venta se crean movimientos de comisión con los campos Liquidado y Nº liquidación sin usar. No existe ningún proceso para liquidarlos, imprimirlos ni facturarlos.

### Alcance
1. **Configuración**
   - RF-1.1 En Configuración de ventas y cobros, nº de serie de las liquidaciones de comisiones y cuenta contable de comisiones.
   - RF-1.2 En el vendedor, nº de proveedor al que se factura su comisión.
2. **Liquidaciones de comisiones**
   - RF-2.1 Cada liquidación guarda nº, vendedor, fecha de liquidación, fecha hasta, factura de compra generada y muestra el total y el nº de movimientos.
   - RF-2.2 Lista de liquidaciones no editable con las acciones Movimientos, Imprimir, Deshacer liquidación y Liquidar comisiones.
3. **Proceso Liquidar comisiones**
   - RF-3.1 Se pide una fecha hasta obligatoria, que por defecto es el último día del mes anterior a la fecha de trabajo, y si se crea factura de compra. Se puede filtrar por vendedor.
   - RF-3.2 Por cada vendedor se liquidan sus movimientos pendientes con fecha de registro hasta la fecha indicada; si no tiene, no se crea liquidación.
   - RF-3.3 Los movimientos liquidados quedan marcados como liquidados y con el nº de liquidación.
   - RF-3.4 Si se pide, se crea una factura de compra en borrador al proveedor del vendedor por el total; sin proveedor o con total menor o igual a cero no se crea y se avisa, sin error.
   - RF-3.5 Con interfaz de usuario se muestra el vendedor en curso y, al terminar, el nº de liquidaciones, el importe total y los avisos.
   - RF-3.6 La liquidación de un vendedor se hace en una codeunit reutilizable (TF0023 la lanzará desde la cola de proyectos). El proceso está en la lista de liquidaciones y en el buscador.
4. **Deshacer liquidación**
   - RF-4.1 Si la factura de compra de la liquidación ya está registrada, no se puede deshacer y se muestra un error.
   - RF-4.2 Si no, tras confirmar se borra la factura borrador (si existe), los movimientos vuelven a pendientes y se borra la liquidación.
5. **Informe de liquidación**
   - RF-5.1 Cabecera con logo y nombre de la empresa, título, nº de liquidación, vendedor y nombre, fecha hasta y nº de página.
   - RF-5.2 Líneas con fecha, tipo y nº de documento, cliente, producto, base, % y comisión; total por liquidación y cada liquidación en página nueva.
   - RF-5.3 Filtros por nº de liquidación y vendedor; la acción Imprimir de la lista lo lanza solo para la liquidación seleccionada.

### Puntos a validar

**Para el cliente**

| # | Tipo | Punto | Bloquea | Responde | Estado |
| --- | --- | --- | --- | --- | --- |
| P-10 | Fuera de alcance | Registro automático de la factura de compra, retenciones, liquidación parcial o de movimientos sueltos, envío del informe por correo, liquidación programada en la cola de proyectos (TF0023) y exportación para nómina (TF0022). | No | Consultor (formación) | Pendiente |

**Internos (LiderIT)**

| # | Tipo | Punto | Bloquea | Responde | Estado / respuesta |
| --- | --- | --- | --- | --- | --- |
| P-1 | Supuesto | Marcado de movimientos (aviso del origen sobre ModifyAll). Decisión: con el filtro Vendedor + Liquidado = No + Fecha registro <= fecha hasta, primero LockTable y CalcSums("Commission Amount (LCY)") para el total, después ModifyAll("Liquidation No.") y por último ModifyAll(Liquidated, true). Al revés, el primer ModifyAll saca los registros del filtro y el segundo no modifica nada. Al deshacer, filtro por Nº liquidación: primero Liquidated = false y al final "Liquidation No." vacío. ModifyAll sin triggers (la tabla no los necesita) en vez de un bucle con Modify. A cuestionar en P1. | No | Programador (P1) / Consultor | Pendiente |
| P-2 | Supuesto | Fecha hasta por defecto. Decisión: en OnOpenPage de la request page, si está vacía, CalcDate('<-CM-1D>', WorkDate()) (fecha de trabajo 15/02/2027 → 31/01/2027). Campo con ShowMandatory y error en OnPreReport si se deja vacía. Se usa WorkDate y no Today porque el origen habla de fecha de trabajo. A cuestionar en P1. | No | Programador (P1) / Consultor | Pendiente |
| P-3 | Supuesto | Reparto de la lógica e interfaz común con TF0023. Decisión: la codeunit "Settle Salesperson Commission_LDR" (TableNo = Salesperson/Purchaser) recibe la fecha hasta y la opción de factura con SetParameters(UpToDate, CreateInvoice) y devuelve resultados con GetSettlementNo y GetWarningText (el report obtiene el total con CalcFields de la liquidación). En OnRun limpia los resultados, comprueba ella misma la configuración (TestField de la serie y, si hay factura, de la cuenta), porque TF0023 la llama sin pasar por el report, y usa Settlement Date = WorkDate(). Sin ninguna interacción (ni siquiera protegida con GuiAllowed) y sin Commit; si tras el LockTable no queda ningún pendiente, sale sin liquidar. Los errores son Error normales. El llamante hace Clear de la instancia antes de cada vendedor y después SetParameters (Clear también borra los parámetros). Deshacer va como UndoSettlement en "Commission Mgt._LDR"; el Confirm está en la acción de la página. A cuestionar en P1. | No | Programador (P1) / Revisor técnico | Pendiente |
| P-4 | Supuesto | Errores en el report manual. Decisión: todo o nada. El report comprueba en OnPreReport la fecha y la configuración y, por cada vendedor, ejecuta la codeunit con Codeunit.Run sin if y sin Commit: si falla un vendedor se revierte todo el proceso (liquidaciones, marcas, facturas y números de serie) y el usuario ve el error, lo corrige y relanza. Motivo: el proceso manual no tiene registro donde dejar errores parciales y relanzarlo es idempotente. Las causas previsibles (sin proveedor, proveedor bloqueado o en divisa, total <= 0) son avisos, no errores (P-8). TF0023, desatendida y con registro, aísla por vendedor con if Codeunit.Run + Commit sobre la misma codeunit. A cuestionar en P1. | No | Programador (P1) / Revisor técnico | Pendiente |
| P-5 | Supuesto | Detección de factura registrada al deshacer. Decisión: si la liquidación tiene nº de factura y no está en Purchase Header, se busca en Purch. Inv. Header (122) por "Pre-Assigned No." = nº de factura (clave Key3; Purch.-Post lo informa en las facturas que no vienen de pedido, PurchPost.Codeunit.al líneas 7100-7101, BC 29 ES). Si existe, error. Si no existe en ningún sitio (borrada a mano), se permite deshacer. A cuestionar en P1. | No | Programador (P1) / Consultor | Pendiente |
| P-6 | Supuesto | Ubicación de la configuración: se amplía Configuración de ventas y cobros (311), como indica el origen. Criterio: los parámetros son una extensión natural del proceso de ventas y no es un módulo aislado. TF0022 y TF0023 deben seguir la misma decisión. | No | Jefe de proyecto LiderIT | Pendiente |
| P-7 | Supuesto | Enfoque del informe: extender el estándar o informe nuevo a partir de una copia del estándar. Recomendación: informe nuevo propio con layout Word, porque no hay ningún informe estándar sobre liquidaciones de comisiones que extender ni copiar; los datos son tablas propias. | Sí | Jefe de proyecto LiderIT | Pendiente |
| P-8 | Supuesto | Factura de compra. Decisión: sin retención de IRPF (fuera de alcance; si aplica, el usuario la añade en el borrador antes de registrar). El IVA sale del grupo del proveedor y de la cuenta, que debe tener Registro directo = Sí (Purchase Line lo exige: PurchaseLine.Table.al línea 4795). Proveedor bloqueado o con divisa: liquidación sin factura y aviso, como sin proveedor. Proveedor con precios IVA incluido: Validate("Prices Including VAT", false) en la cabecera antes de crear la línea, porque el total es neto. A cuestionar en P1. | No | Consultor (formación) | Pendiente |
| P-9 | Supuesto | Claves de "Commission Entry_LDR" (objeto de TF0020). TF0020 ya define "Salesperson Code, Liquidated, Posting Date" con SumIndexFields = "Commission Amount (LCY)", que sirve para el filtro y el CalcSums del proceso: no se duplica. TF0021 solo añade en esa tabla la clave "Liquidation No." con SumIndexFields = "Commission Amount (LCY)" para los FlowFields de la liquidación, el deshacer y el DataItemLink del informe. | No | Programador / Revisor técnico | Pendiente |

## 2. Descripción desarrollo

Se crean la tabla de liquidaciones, el proceso de liquidación con su codeunit reutilizable, el deshacer y el informe Word, y se amplían la configuración de ventas y el vendedor. Se realizarán las siguientes modificaciones:

### 1. Configuración
**Ubicación:** Tabla Sales & Receivables Setup (311) y página Sales & Receivables Setup (459); tabla Salesperson/Purchaser (13) y página Salesperson/Purchaser Card (5116).
Se añaden dos campos a Configuración de ventas y cobros, en un grupo nuevo «Comisiones», y el proveedor en la ficha del vendedor (en la extensión del vendedor creada en TF0020).

| Campo | Tipo | Relación | Tabla | Comentario |
| --- | --- | --- | --- | --- |
| Commission Settlement Nos. (Nº serie liquidación comisiones) | Code[20] | No. Series | Sales & Receivables Setup (311) | Obligatorio para liquidar |
| Commission Account (Cuenta comisiones) | Code[20] | G/L Account | Sales & Receivables Setup (311) | Obligatoria solo si se pide factura |
| Vendor No. (Nº proveedor) | Code[20] | Vendor | Salesperson/Purchaser (13) | Proveedor al que se factura la comisión |


### 2. Liquidaciones de comisiones
**Ubicación:** Tabla y página nuevas; enlazan con Commission Entry_LDR (TF0020).
Se crea la tabla «Commission Settlement» con el patrón estándar de nº de serie: en OnInsert, si el nº está vacío, TestField de la serie en la configuración, "No. Series" = esa serie y "No." = GetNextNo("No. Series", WorkDate()) de la codeunit «No. Series» (no NoSeriesManagement, obsoleta). La codeunit rellena vendedor y fechas y hace Insert(true). Los totales son FlowFields sobre los movimientos con el mismo nº de liquidación.

La lista «Commission Settlements_LDR» (UsageCategory = Lists) no permite insertar, modificar ni borrar: las liquidaciones solo se crean con el proceso y se eliminan con Deshacer.

| Campo | Tipo | Comentario |
| --- | --- | --- |
| No. | Code[20] | PK. Nº de serie de la configuración al insertar |
| Salesperson Code | Code[20] | Relación con Salesperson/Purchaser |
| Settlement Date | Date | Fecha de la liquidación (fecha de trabajo) |
| Up To Date | Date | Fecha hasta la que se liquidó |
| Total Amount (LCY) | Decimal | FlowField: suma de Commission Amount (LCY) de los movimientos con Liquidation No. = No. |
| No. of Entries | Integer | FlowField: nº de movimientos de la liquidación |
| Purchase Invoice No. | Code[20] | Factura de compra borrador generada (si se generó) |
| No. Series | Code[20] | Patrón estándar de nº de serie |

- Movimientos: abre Commission Entries_LDR filtrada por el nº de liquidación.
- Imprimir: copia la liquidación seleccionada, SetRecFilter y lanza el informe con esa copia.
- Deshacer liquidación: pide confirmación y llama a UndoSettlement.
- Liquidar comisiones: lanza el proceso.

### 3. Proceso Liquidar comisiones
**Ubicación:** Report de proceso nuevo (ProcessingOnly, UsageCategory = Tasks) sobre Salesperson/Purchaser (13), RequestFilterFields = Code.
La request page pide Fecha hasta (obligatoria; por defecto, último día del mes anterior a la fecha de trabajo) y Crear factura de compra. En OnPreReport se comprueban la fecha y la configuración. Por cada vendedor el report hace Clear de la codeunit «Settle Salesperson Commission_LDR», SetParameters y Codeunit.Run sin if (todo o nada, P-4); si no se ha creado liquidación pasa al siguiente.

La codeunit filtra los movimientos del vendedor con Liquidado = No y fecha de registro hasta la fecha indicada, hace LockTable y CalcSums. Si hay, inserta la liquidación (Insert(true)) y marca los movimientos con dos ModifyAll en el orden de P-1. Toda la lógica está en la codeunit, sin interfaz ni Commit, para que TF0023 la reutilice desde la cola de proyectos.

Si se pide factura, con proveedor no bloqueado y en DL y total mayor que cero, crea una factura de compra: Purchase Header tipo Factura con Insert(true), Validate del proveedor, "Prices Including VAT" = false y «Vendor Invoice No.» = nº de liquidación; una línea de tipo Cuenta con la cuenta configurada, cantidad 1 y coste unitario directo = total. Guarda el nº de factura en la liquidación.

- Vendedor sin proveedor, proveedor bloqueado o con divisa, o total <= 0: liquidación creada sin factura; la codeunit devuelve el aviso con GetWarningText y el report lo acumula.
- Dialog con el vendedor en curso y mensaje final solo si GuiAllowed; programado en segundo plano no muestra nada.
- El report se incluye en la lista de liquidaciones y en el buscador («Liquidar comisiones»).
- Mensaje: “Se han creado %1 liquidaciones por un total de %2. Avisos: %3”
- Mensaje: “El vendedor %1 no tiene proveedor: la liquidación %2 se ha creado sin factura.”
- Mensaje: “El proveedor %1 del vendedor %2 está bloqueado o tiene divisa: la liquidación %3 se ha creado sin factura.”
- Mensaje: “La liquidación %1 tiene un total de %2: no se crea factura de compra.”
- Mensaje: “Indique la fecha hasta.”

### 4. Deshacer liquidación
**Ubicación:** Página Commission Settlements_LDR; tablas Purchase Header (38) y Purch. Inv. Header (122).
La acción pide confirmación y llama a UndoSettlement de «Commission Mgt._LDR», que bloquea y relee la liquidación (LockTable + Get) para que dos usuarios no la deshagan a la vez. Si la factura ya está registrada (se localiza por «Pre-Assigned No.», P-5) da error. Si no, borra la factura borrador con Delete(true) (también borra sus líneas), devuelve los movimientos a pendientes con dos ModifyAll en el orden de P-1 y borra la liquidación.

- Mensaje: “¿Desea deshacer la liquidación %1? Se eliminará la factura de compra borrador %2 y los movimientos volverán a quedar pendientes.”
- Mensaje: “La factura de compra %1 de la liquidación %2 ya está registrada. No se puede deshacer la liquidación.”

### 5. Informe de liquidación
**Ubicación:** Informe nuevo con layout Word; tabla Company Information (79) para logo y nombre.
DataItems: Commission Settlement → Commission Entry (DataItemLink «Liquidation No.» = field(«No.»)). Company Information se lee una vez con CalcFields(Picture). Cada liquidación empieza en página nueva y termina con su total.

RequestFilterFields: nº de liquidación y vendedor; UsageCategory = ReportsAndAnalysis para encontrarlo en el buscador. Desde la lista se lanza con la liquidación seleccionada (SetRecFilter sobre una copia).

| Parte | Contenido |
| --- | --- |
| Cabecera | Logo y nombre de la empresa, título, nº de liquidación, vendedor y nombre, fecha hasta, nº de página |
| Líneas | Fecha, tipo y nº de documento, cliente, producto, base, % y comisión |
| Pie de liquidación | Total de comisión |


### Alcance técnico
- TableExtension 50002 «Sales & Receivables Setup_LDR» (extiende tabla Sales & Receivables Setup (311)): Commission Settlement Nos. y Commission Account (dueño TF0021)
- PageExtension 50004 «Sales & Receivables Setup_LDR» (extiende página Sales & Receivables Setup (459)): grupo «Commissions» con los dos campos
- TableExtension 50000 «Salesperson/Purchaser_LDR» (extiende tabla Salesperson/Purchaser (13)): campo Vendor No. (objeto de TF0020; se amplía)
- PageExtension 50002 «Salesperson/Purchaser_LDR» (extiende página Salesperson/Purchaser Card (5116)): campo Vendor No. (objeto de TF0020, mismo nombre que allí)
- Table 50002 «Commission Settlement_LDR»: cabecera de liquidación
- Page 50003 «Commission Settlements_LDR»: lista no editable con acciones Movimientos, Imprimir, Deshacer liquidación y Liquidar comisiones
- Report 50000 «Settle Commissions_LDR»: proceso por lotes; recorre vendedores y llama a la codeunit de liquidación
- Report 50001 «Commission Settlement_LDR»: informe Word de la liquidación (layout CommissionSettlement.docx)
- Codeunit 50002 «Settle Salesperson Commission_LDR»: TableNo = Salesperson/Purchaser; SetParameters, OnRun y Get…; liquida un vendedor y crea su factura, sin interfaz ni Commit (dueño TF0021; TF0023 la reutiliza con if Codeunit.Run)
- Codeunit 50000 «Commission Mgt._LDR»: se añade UndoSettlement (objeto de TF0020)
- Table 50001 «Commission Entry_LDR»: se usan Liquidated y Liquidation No.; se añade la clave Liquidation No. con SumIndexFields (P-9) (objeto de TF0020)
- PermissionSet 50000 «Commissions_LDR»: se añaden los objetos nuevos (objeto de TF0020)
- Sin suscripciones a eventos: no se modifica lógica estándar; la factura se crea con Insert(true) y Validate para que actúen los triggers estándar.
- Codeunit de liquidación sin Message, Confirm, Dialog ni Commit: los mensajes al usuario y el progreso están en el report y la página, protegidos con GuiAllowed.
- Se añade la clave "Liquidation No." con SumIndexFields en Commission Entry_LDR (P-9); la clave de vendedor ya la crea TF0020.
- Captions en inglés con Comment = 'ESP="..."' y traducción es-ES.
- Layout Word CommissionSettlement.docx en src/report/layout.

### Consideraciones
- Depende de TF0020 (movimientos, Commission Mgt._LDR, extensión del vendedor y permission set). Los nombres de campos de Commission Entry_LDR deben coincidir con los de TF0020.
- Las decisiones de P-1 a P-5 y P-8 resuelven los avisos y ejercicios del origen (orden de ModifyAll, valor por defecto con CalcDate, interfaz de la codeunit, todo o nada, factura registrada, factura sin IRPF). En sdd-implementar el programador debe cuestionarlas en P1 antes de construir.
- La codeunit se crea ya en TF0021 para no refactorizar en TF0023; TF0023 solo la reutiliza y comprueba que funciona sin interfaz.
- Concurrencia (decisión): LockTable sobre los movimientos antes del CalcSums y los ModifyAll; si dos usuarios, o el report y la cola de TF0023, liquidan el mismo vendedor a la vez, el segundo espera y, al releer, ya no encuentra pendientes. El nº de serie queda bloqueado por GetNextNo hasta el final de la transacción. En el deshacer se bloquea la liquidación.
- La factura borrador queda abierta: el usuario la revisa y la registra. Una vez registrada, la liquidación no se puede deshacer.
- Configuración previa: serie de liquidaciones, cuenta de comisiones con grupos contables e IVA y proveedor en cada vendedor que facture.
- Permisos: «Commissions_LDR» cubre los objetos propios; quien liquide con factura necesita además los permisos estándar de compras para crear y borrar facturas (Purchase Header y Purchase Line).
- La app declara application 28 y el estándar consultado es BC 29 ES; no se usan eventos, pero conviene compilar contra 28.
- El origen no pide tests automáticos; si se hacen, van en la app de test.
- Entrega: documentación técnica con explicación de la solución, estructura de objetos, funciones de la codeunit, capturas de código, del informe y de funcionamiento, y problemas o dudas encontrados.
- Referencia LiderIT: el cliente kassandra tiene un informe de comisiones de vendedores (ComisionesVendedores.Report.al) que puede servir de modelo de layout.

### Reparto de tareas
Al aprobar la tarea, cada fila se crea como sub-issue en GitHub.

| Tarea | Descripción | Depende de | Hecho cuando |
| --- | --- | --- | --- |
| T-01 | Campos de configuración y proveedor del vendedor | TF0020 | Compila y los campos se editan en las fichas (A-1) |
| T-02 | Tabla y lista de liquidaciones con nº de serie y FlowFields | T-01 | Inserción con nº de serie y FlowFields correctos |
| T-03 | Codeunit Settle Salesperson Commission_LDR (liquidación y factura) | T-02 | Pasan A-3 a A-6 |
| T-04 | Report Liquidar comisiones (request page, progreso, mensaje final) | T-03 | Pasan A-2, A-7 a A-9 |
| T-05 | UndoSettlement y acciones de la lista | T-03 | Pasan A-10 a A-12 |
| T-06 | Informe Word de liquidación | T-02 | Pasan A-13 y A-14 |
| T-07 | Permisos, traducciones y documentación técnica | T-04, T-05, T-06 | Permission set completo, XLIFF completo y documentación entregada |

## 3. Documentación técnica del desarrollo realizado

_Pendiente del técnico._

## 4. Guion de pruebas funcional key-user

Pruebas que valida el consultor en el sandbox de formación con la empresa CRONUS ES y fecha de trabajo 15/02/2027.

### Parametrización previa
- Configuración de ventas y cobros: serie LIQCOM (LIQ-0001…) y cuenta de comisiones de servicios profesionales con grupos contables e IVA y Registro directo = Sí.
- Tres vendedores de prueba: V1 con proveedor de prueba PV1 (en DL, precios sin IVA), V2 sin proveedor y V3 con proveedor.
- Movimientos de comisión de TF0020 (al registrar ventas): V1: 15/01/2027 factura base 1.000,00 € al 5 % (50,00 €), 20/01/2027 abono base -200,00 € al 5 % (-10,00 €), 10/02/2027 factura base 2.000,00 € al 5 % (100,00 €). V2: 25/01/2027 factura base 500,00 € al 10 % (50,00 €), 05/02/2027 factura base 300,00 € al 10 % (30,00 €). V3: 28/01/2027 abono base -100,00 € al 10 % (-10,00 €).

### Escenarios de prueba
| Prueba | Requisito | Escenario | Resultado esperado | OK |
| --- | --- | --- | --- | --- |
| A-1 | RF-1.1, RF-1.2 | Informar la serie y la cuenta en Configuración de ventas y cobros y el proveedor PV1 en la ficha de V1 | Los campos se guardan; solo admiten series, cuentas y proveedores existentes |  |
| A-2 | RF-3.1 | Abrir Liquidar comisiones con fecha de trabajo 15/02/2027; después borrar la fecha hasta y aceptar | Fecha hasta propuesta 31/01/2027; sin fecha, error «Indique la fecha hasta.» y no se crea nada |  |
| A-3 | RF-3.2, RF-3.3, RF-2.1 | Liquidar hasta 31/01/2027 con Crear factura de compra marcado, sin filtro de vendedor | LIQ-0001 de V1 (2 movimientos, total 40,00 €), LIQ-0002 de V2 (1 movimiento, 50,00 €) y LIQ-0003 de V3 (1 movimiento, -10,00 €). Los movimientos de febrero siguen pendientes; los liquidados tienen Liquidado = Sí y su nº de liquidación |  |
| A-4 | RF-3.4 | Revisar la liquidación LIQ-0001 y su factura de compra | Factura borrador al proveedor PV1 con Nº factura proveedor LIQ-0001 y una línea de tipo Cuenta (cuenta de comisiones), cantidad 1, coste unitario 40,00 €; su nº figura en LIQ-0001 |  |
| A-5 | RF-3.4 | Caso límite: LIQ-0002 de V2, sin proveedor | Liquidación creada sin factura; el mensaje final incluye el aviso «El vendedor V2 no tiene proveedor…» |  |
| A-6 | RF-3.4 | Caso límite: LIQ-0003 de V3, total -10,00 € | Liquidación creada sin factura; aviso «La liquidación LIQ-0003 tiene un total de -10,00…» |  |
| A-7 | RF-3.5 | Mensaje final de A-3 | «Se han creado 3 liquidaciones por un total de 80,00. Avisos: 2» con los dos avisos; durante el proceso se ve el vendedor en curso |  |
| A-8 | RF-3.2 | Caso límite: volver a lanzar hasta 31/01/2027 | «Se han creado 0 liquidaciones…»; no se crean liquidaciones, facturas ni cambios en movimientos |  |
| A-9 | RF-3.5, RF-3.6 | Buscar «Liquidar comisiones» en el buscador y programarlo desde la request page (Programar) hasta 28/02/2027 con filtro de vendedor V2 | Se ejecuta en segundo plano sin errores de interfaz: crea la liquidación de V2 (30,00 €) sin mostrar diálogo ni mensaje |  |
| A-10 | RF-4.2 | Deshacer LIQ-0001 y responder No a la confirmación; repetir respondiendo Sí | Con No no cambia nada. Con Sí desaparecen la factura borrador y LIQ-0001, y los dos movimientos de enero de V1 vuelven a pendientes, sin nº de liquidación |  |
| A-11 | RF-4.1 | Liquidar V1 de nuevo hasta 31/01/2027 con factura, registrar la factura y deshacer la liquidación | Error «La factura de compra … ya está registrada. No se puede deshacer la liquidación.»; liquidación y movimientos sin cambios |  |
| A-12 | RF-2.2 | En la lista, intentar editar o borrar una liquidación y usar la acción Movimientos sobre la de V1 | No se puede editar ni borrar; Movimientos muestra los 2 movimientos de la liquidación, que suman su total |  |
| A-13 | RF-5.1, RF-5.2, RF-5.3 | Imprimir desde la lista la liquidación de V1 (40,00 €) | Solo esa liquidación: logo y nombre de CRONUS, título, nº, vendedor V1 y nombre, fecha hasta 31/01/2027, nº de página; 2 líneas (50,00 € y -10,00 €) y total 40,00 €, igual que en Movimientos |  |
| A-14 | RF-5.2, RF-5.3 | Lanzar el informe desde el buscador filtrando por los vendedores V2 y V3 | Una página por liquidación, cada una con su total (50,00 €, 30,00 € y -10,00 €) |  |
| A-15 | RF-3.4 | Caso límite (P-4): quitar Registro directo a la cuenta de comisiones, dejar pendientes movimientos de V1 y V2 y liquidar hasta 28/02/2027 con Crear factura de compra marcado | Error de la cuenta al crear la línea de la factura de V1; no se crea ninguna liquidación ni factura y todos los movimientos siguen pendientes |  |

## Fuentes
- Tarea de formación TF0021 – Liquidación de comisiones (apartado completo); reparto del Bloque 5 (dueños de objetos y decisiones comunes); campos de Commission Entry según el origen de TF0020.
- BC 29 ES: Sales/Setup/SalesReceivablesSetup.Table.al y .Page.al; CRM/Team/SalespersonPurchaser.Table.al y SalespersonPurchaserCard.Page.al; Purchases/History/PurchInvHeader.Table.al (campo 111 Pre-Assigned No.); Business Foundation NoSeries.Codeunit.al; Foundation/Company/CompanyInformation.Table.al. Purchases/Posting/PurchPost.Codeunit.al (líneas 7100-7101, Pre-Assigned No.); Purchases/Document/PurchaseLine.Table.al (línea 4795, Direct Posting); Purchases/Document/PurchaseHeader.Table.al (OnDelete, línea 3049).
- https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-modifyall-method
- https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/session/session-guiallowed-method
- Referencia LiderIT: kassandra (informe de comisiones de vendedores).
- Revisado con bc-code-intel (especialistas: alex-architect; sin contenido específico aplicable: decisiones del revisor contrastadas con el código estándar BC 29 ES).

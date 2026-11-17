# Tarea de desarrollo TF0020 — Comisiones de vendedores

Código ERPIT: pendiente · Código en el origen: TF0020
Cliente: LiderIT · Fecha: 17/11/2026 · Proyecto: Formación – Bloque 5 (Eventos, registro y procesos) · Consultor: Alejandro González Torres
Origen: Tarea de formación TF0020 – Comisiones de vendedores (19/10/2026), Bloque 5 · Riesgo: ROJO (suscripción a eventos de registro de ventas de Sales-Post; los movimientos se crean dentro de la transacción de registro) · Estado: En GitHub · Puntos a validar pendientes: 7 (2 bloqueantes)

## 1. Descripción funcional

### Contexto
La empresa paga a sus vendedores una comisión por cada factura de venta registrada y se la descuenta al registrar un abono. Hoy se calcula a mano en una hoja de cálculo a partir del listado de facturas. Se requiere que Business Central genere automáticamente un movimiento de comisión al registrar.

### Situación actual
El estándar ya tiene vendedores (tabla Salesperson/Purchaser) con el campo «% Comisión», visible en la ficha, pero no lo usa para calcular nada. No hay ningún desarrollo previo en el repositorio de prácticas.

### Alcance
1. **Configuración**
   - RF-1.1 El porcentaje de comisión de cada vendedor es el campo estándar «% Comisión» de la ficha del vendedor; no se crea un campo nuevo.
   - RF-1.2 Nuevo campo «Excluir de comisión» en la ficha del producto para productos que no generan comisión (portes, embalajes).
2. **Movimientos de comisión**
   - RF-2.1 Nueva tabla de movimientos de comisión con los datos del documento, vendedor, cliente, producto, base, porcentaje aplicado, importe, liquidación y usuario.
   - RF-2.2 Lista de movimientos de comisión de solo consulta: no se pueden crear, modificar ni borrar a mano; con acción «Navegar».
   - RF-2.3 En la ficha del vendedor, «Comisión pendiente (DL)»: suma de las comisiones no liquidadas, con acceso a sus movimientos.
3. **Generación de movimientos al registrar**
   - RF-3.1 Al registrar una factura de venta se crea un movimiento por cada línea de tipo Producto con cantidad distinta de 0 y producto no excluido.
   - RF-3.2 Al registrar un abono de venta se crea el movimiento con base e importe en negativo.
   - RF-3.3 El vendedor es el de la cabecera del documento registrado; si no tiene vendedor o su porcentaje es 0, se registra sin error y sin movimiento.
   - RF-3.4 Base sin IVA en divisa local y comisión = base × % / 100, redondeadas a la precisión de importes de la configuración de contabilidad.
4. **Integración con Navegar**
   - RF-4.1 Desde la factura o el abono registrados, «Navegar» muestra la línea de movimientos de comisión con su número de registros y, al pulsarla, abre esos movimientos.

### Puntos a validar

**Internos (LiderIT)**

| # | Tipo | Punto | Bloquea | Responde | Estado / respuesta |
| --- | --- | --- | --- | --- | --- |
| P-1 | Supuesto | Nº de movimiento con AutoIncrement y no con FindLast + 1 de los movimientos estándar. Motivo: no es un movimiento contable ni fiscal, no se exige numeración sin huecos y FindLast + 1 obliga a LockTable sobre la tabla, lo que serializa los registros de ventas concurrentes. Consecuencia aceptada: el contador de SQL no se devuelve en un rollback, así que quedan huecos cuando un registro falla. Se inserta con «Entry No.» = 0 y el valor asignado se lee del registro tras el Insert. Alternativa a comentar en P1: el estándar numera hoy sus movimientos con la codeunit Sequence No. Mgt. (Sales-Post llama a SetPreviewMode al empezar). Revisado por el revisor técnico: se mantiene. | Sí | Consultor / formador LiderIT | Pendiente |
| P-2 | Supuesto | Eventos por línea (OnAfterSalesInvLineInsert / OnAfterSalesCrMemoLineInsert) y no OnAfterPostSalesDoc (TF0010). Motivo: OnAfterPostSalesDoc se lanza después del Commit del registro; un error ahí deja la factura registrada sin comisión. Los eventos por línea van dentro de la misma transacción y ya traen la línea registrada. Con envío y facturación parcial solo se genera comisión de lo facturado (el envío sin factura no crea líneas de factura). Se debe cuestionar en P1. Revisado: correcto. El evento de línea se lanza también para líneas de comentario y de cuenta; por eso el filtro Type = Item va en la codeunit. | Sí | Consultor / formador LiderIT | Pendiente |
| P-3 | Supuesto | Conversión a DL como el estándar: si el documento tiene divisa, ExchangeAmtFCYToLCY de Currency Exchange Rate con la fecha de registro, la divisa y el «Currency Factor» de la cabecera; redondeo con «Amount Rounding Precision» de la configuración de contabilidad. La comisión se calcula sobre la base ya redondeada y se redondea otra vez. Se acepta una diferencia de céntimos frente a lo contabilizado, que el estándar redondea por agrupación. Se debe cuestionar en P1. | No | Consultor / formador LiderIT | Pendiente |
| P-4 | Supuesto | Vista previa de registro: Commission Mgt._LDR sale sin hacer nada si la codeunit Gen. Jnl.-Post Preview (19) devuelve IsActive() = true. Se usa esta comprobación y no el parámetro PreviewMode porque solo lo trae OnAfterSalesInvLineInsert; OnAfterSalesCrMemoLineInsert no lo tiene (BC 28 y 29), y así facturas y abonos se tratan igual en un único sitio. Motivo frente a dejar que el rollback lo deshaga: no se hace trabajo inútil y no se consumen números del AutoIncrement (P-1). Los movimientos no se ven en la ventana de vista previa (no se suscribe a Posting Preview Event Handler); mostrarlos queda fuera de alcance. | No | Revisor técnico LiderIT | Pendiente |
| P-5 | Supuesto | Base = campo «Amount» de la línea registrada (neto sin IVA, después del descuento de línea y del descuento de factura). Cliente del movimiento = «Sell-to Customer No.» de la cabecera. «Amount» es sin IVA también cuando la cabecera tiene «Precios IVA incluido». Revisado: correcto. | No | Consultor / formador LiderIT | Pendiente |
| P-6 | Supuesto | Permisos (decisión del revisor): 1) Commission Mgt._LDR, única que inserta, con Permissions = tabledata "Commission Entry_LDR" = ri. 2) PermissionSet «Commissions_LDR» (Assignable) con lectura directa de la tabla y ejecución de los objetos de comisiones, para quien consulta. 3) PermissionSetExtension del conjunto estándar «D365 SALES DOC, POST» con tabledata "Commission Entry_LDR" = ri (indirecto): sin ella, un usuario que registra ventas y no tiene Commissions_LDR recibiría un error de permisos y no podría registrar. No se usa InherentPermissions en la tabla: daría lectura e inserción a cualquier usuario. En Navegar, si el usuario no tiene ReadPermission sobre la tabla, el suscriptor no añade la línea. Se debe cuestionar en P1. | No | Revisor técnico LiderIT | Pendiente |
| P-7 | Supuesto | La app declara application 28 y el estándar local es BC 29 ES. Comprobado con bc-observatory (bc_diff_object 28 → 29): Sales-Post (80) solo añade OnBeforeUpdateSalesOrderLineIfExist y Navigate (344) solo añade FindSpendRequests; las firmas de OnAfterSalesInvLineInsert, OnAfterSalesCrMemoLineInsert, OnAfterNavigateFindRecords y OnBeforeShowRecords son iguales en 28 y 29. Se puede publicar en 28. | No | Revisor técnico LiderIT | Resuelto: Firmas de los cuatro eventos idénticas en BC 28 y 29 (bc_diff_object). |
| P-8 | Fuera de alcance | Facturas y abonos de anticipo (Sales-Post Prepayments), documentos de servicio, recálculo de movimientos ya creados si cambia el % del vendedor, comisiones por producto o cliente (TF0022), liquidación (TF0021) y proceso automático (TF0023). | No | Consultor / formador LiderIT | Pendiente |

## 2. Descripción desarrollo

Toda la lógica se centraliza en la codeunit «Commission Mgt._LDR»; los suscriptores solo llaman a sus funciones, igual que en las tareas del Bloque 4. Se realizarán las siguientes modificaciones:

### 1. Configuración
**Ubicación:** Tabla Salesperson/Purchaser (13), página Salesperson/Purchaser Card (5116); tabla Item (27), página Item Card (30).
El porcentaje es el campo estándar «Commission %» (campo 3) de Salesperson/Purchaser, que ya se ve en la ficha del vendedor y en la lista. No se crea campo nuevo.

Se añade al producto un campo booleano, visible en la ficha en la pestaña General.

| Campo | Tipo | Tabla | Comentario |
| --- | --- | --- | --- |
| Exclude from Commission (ESP «Excluir de comisión») | Boolean | Item (27) | Si está activo, las líneas de ese producto no generan comisión |


### 2. Movimientos de comisión
**Ubicación:** Tabla nueva Commission Entry_LDR; página nueva Commission Entries_LDR; ficha Salesperson/Purchaser Card (5116).
Tabla de movimientos con estos campos. «Entry No.» es AutoIncrement (P-1): se inserta con 0 y lo asigna la base de datos. LookupPageId y DrillDownPageId apuntan a la lista. DataClassification CustomerContent.

La lista no es editable (Editable, InsertAllowed, ModifyAllowed y DeleteAllowed = false). Su acción «Navegar» abre la página estándar Navigate (344) con SetDoc(«Posting Date», «Document No.») y Run.

| Campo | Tipo | Relación | Comentario |
| --- | --- | --- | --- |
| Entry No. | Integer | — | PK, AutoIncrement |
| Posting Date | Date | — | Fecha de registro del documento |
| Document Type | Enum Commission Document Type_LDR | — | Invoice / Credit Memo |
| Document No. | Code[20] | — | Nº de la factura o abono registrado |
| Document Line No. | Integer | — | Nº de línea del histórico |
| Salesperson Code | Code[20] | Salesperson/Purchaser | Vendedor de la cabecera |
| Customer No. | Code[20] | Customer | Sell-to Customer No. (P-5) |
| Item No. | Code[20] | Item |  |
| Base Amount (LCY) | Decimal | — | Neto sin IVA en DL; negativo en abonos |
| Commission % | Decimal | — | % del vendedor en el momento del registro; se guarda, no se recalcula |
| Commission Amount (LCY) | Decimal | — | Base × % / 100, redondeado; negativo en abonos |
| Liquidated | Boolean | — | Lo usará TF0021 |
| Liquidation No. | Code[20] | — | Lo usará TF0021 |
| User ID | Code[50] | — | UserId() del usuario que registra |

- Claves: PK «Entry No.»; secundaria «Salesperson Code, Liquidated, Posting Date» con SumIndexFields = «Commission Amount (LCY)» (cubre el FlowField); secundaria «Document No., Posting Date» para el filtro de Navegar.
- Ficha del vendedor: FlowField «Pending Commission (LCY)» (ESP «Comisión pendiente (DL)») = Sum de «Commission Amount (LCY)» con Salesperson Code = field(Code) y Liquidated = const(false); no editable; DrillDown a la lista filtrada.
- DataClassification: «User ID» EndUserIdentifiableInformation; el resto CustomerContent.

### 3. Generación de movimientos al registrar
**Ubicación:** Codeunit Sales-Post (80); tablas Sales Invoice Line (113), Sales Cr.Memo Line (115) y sus cabeceras (112, 114); Currency Exchange Rate (330); General Ledger Setup (98).
La codeunit de suscriptores se suscribe a OnAfterSalesInvLineInsert y OnAfterSalesCrMemoLineInsert de Sales-Post y llama a «Commission Mgt._LDR» con la línea y la cabecera registradas. Signo +1 en facturas y −1 en abonos.

Se descarta OnAfterPostSalesDoc (P-2): se lanza después del Commit, fuera de la transacción del registro. Los eventos por línea se lanzan dentro, con la línea ya insertada, así que factura y comisión se guardan o se deshacen juntas. En facturación parcial, cada factura genera comisión solo de lo que factura.

Importe en DL (P-3): sin divisa, «Amount» tal cual; con divisa, ExchangeAmtFCYToLCY(«Posting Date», «Currency Code», «Amount», «Currency Factor») y Round con «Amount Rounding Precision». Comisión = Round(base × % / 100).

- Se crea movimiento solo si: no es vista previa (P-4), Type = Item, Quantity <> 0, el producto no tiene «Exclude from Commission», la cabecera tiene «Salesperson Code» y el % de ese vendedor es distinto de 0.
- En cualquier otro caso sale sin hacer nada y sin error: nunca se impide registrar por la comisión. Sin Commit, Message ni Confirm en la codeunit (va dentro de la transacción del registro).
- Signo: en abonos la línea registrada trae «Amount» y «Quantity» en positivo; la base y la comisión se multiplican por −1 después de convertir y redondear. «Commission %» se guarda siempre en positivo.
- Lecturas con SetLoadFields (Item: Exclude from Commission; Salesperson: Commission %). GLSetup.Get por línea es aceptable porque el servidor cachea la configuración; no hace falta SingleInstance.
- Permisos de inserción según P-6.

### 4. Integración con Navegar
**Ubicación:** Página Navigate (344), tabla Document Entry (265).
OnAfterNavigateFindRecords: si el usuario tiene ReadPermission sobre la tabla, se filtran los movimientos con SetFilter por DocNoFilter (Document No.) y PostingDateFilter (Posting Date) y, si hay, se añade la línea con DocumentEntry.InsertIntoDocEntry(Database::"Commission Entry_LDR", TableCaption, Count). DocumentEntry es el registro temporal de la propia página (SourceTableTemporary).

OnBeforeShowRecords: si TempDocumentEntry."Table ID" es la tabla de comisiones, se abre «Commission Entries_LDR» con los mismos filtros y se pone IsHandled := true. Para cualquier otra tabla no se toca IsHandled.


### Alcance técnico
- Table 50001 «Commission Entry_LDR»: movimientos de comisión (objeto compartido con TF0021 y TF0022)
- Page 50000 «Commission Entries_LDR»: lista no editable con acción Navegar (TF0022 añade acciones de exportación)
- Enum 50000 «Commission Document Type_LDR»: Invoice / Credit Memo
- Codeunit 50000 «Commission Mgt._LDR»: lógica central: crear movimiento desde línea de factura o abono, conversión a DL, Navegar (la amplían TF0021, TF0022 y TF0023)
- Codeunit 50001 «Commission Subscribers_LDR»: suscriptores de Sales-Post y Navigate; solo llaman a Commission Mgt._LDR
- TableExtension 50000 «Salesperson/Purchaser_LDR» (extiende tabla Salesperson/Purchaser (13)): FlowField Pending Commission (LCY) (TF0021 añade Vendor No.)
- PageExtension 50002 «Salesperson/Purchaser_LDR» (extiende página Salesperson/Purchaser Card (5116)): muestra Pending Commission (LCY) con DrillDown (TF0022 añade la acción Commission Rates)
- TableExtension 50001 «Item_LDR» (extiende tabla Item (27)): campo Exclude from Commission
- PageExtension 50003 «Item Card_LDR» (extiende página Item Card (30)): muestra Exclude from Commission
- PermissionSet 50000 «Commissions_LDR»: permisos de los objetos de comisiones (cada tarea añade los suyos)
- PermissionSetExtension 50000 «D365 Sales Doc Post_LDR» (extiende permission set D365 SALES DOC, POST): permiso indirecto de lectura e inserción en Commission Entry_LDR para quien registra ventas (P-6)
- Suscripciones a eventos de Sales-Post (registro) y de Navigate, verificadas en BC 29 ES y sin cambios en BC 28; los suscriptores no contienen lógica.
- Captions en inglés con Comment = 'ESP="..."' y traducción es-ES.
- Sin cambios en la contabilización estándar: los movimientos de comisión no generan asientos.
- Suscripción a OnAfterSalesInvLineInsert de Codeunit Sales-Post (80): crear el movimiento de comisión de cada línea de factura registrada (verificado: BaseApp/Source/Base Application/Sales/Posting/SalesPost.Codeunit.al:9703 (BC 29 ES); firma igual en BC 28 (bc-observatory bc_diff_object 28→29))
- Suscripción a OnAfterSalesCrMemoLineInsert de Codeunit Sales-Post (80): crear el movimiento en negativo de cada línea de abono registrado (verificado: BaseApp/Source/Base Application/Sales/Posting/SalesPost.Codeunit.al:9736 (BC 29 ES); firma igual en BC 28 (bc-observatory bc_diff_object 28→29))
- Suscripción a OnAfterNavigateFindRecords de Page Navigate (344): añadir la línea de movimientos de comisión en Navegar (verificado: BaseApp/Source/Base Application/Foundation/Navigate/Navigate.Page.al:2289 (BC 29 ES); firma igual en BC 28 (bc-observatory bc_diff_object 28→29))
- Suscripción a OnBeforeShowRecords de Page Navigate (344): abrir la lista de movimientos de comisión filtrada (verificado: BaseApp/Source/Base Application/Foundation/Navigate/Navigate.Page.al:2331 (BC 29 ES); firma igual en BC 28 (bc-observatory bc_diff_object 28→29))

### Consideraciones
- Decisión del consultor: las preguntas de ejercicio del origen (AutoIncrement frente a FindLast + 1, conversión a DL y redondeo, eventos por línea frente a OnAfterPostSalesDoc, facturación parcial y vista previa) quedan resueltas en P-1 a P-4. En sdd-implementar el programador debe cuestionarlas en P1 antes de construir y anotar si las mantiene o propone otra cosa.
- Los eventos homónimos de Sales-Post Prepayments (442) no se suscriben: los anticipos no generan comisión (P-8).
- La comisión se genera también en abonos que vienen de devoluciones o de «Corregir/Cancelar» una factura registrada, porque pasan por Sales-Post.
- Objetos compartidos según el reparto del Bloque 5: TF0020 crea la tabla, la página, el enum, las dos codeunits, la extensión del vendedor y el PermissionSet; TF0021 a TF0023 los amplían con el mismo nombre.
- Sin impacto sobre lo instalado: main no tiene objetos ni suscripciones.
- Referencia: kassandra tiene un informe de comisiones de vendedores (ComisionesVendedores.Report.al) que calcula sobre documentos registrados y ajusta el signo de los abonos; sirve de contraste funcional, no se reutiliza código.
- La app declara application 28 y el estándar consultado es BC 29 ES; firmas comprobadas también en 28 (P-7).
- Nuevo objeto respecto al reparto del Bloque 5: PermissionSetExtension «D365 Sales Doc Post_LDR» (P-6). Lo crea TF0020; TF0021 a TF0023 solo lo amplían si insertan o modifican movimientos en procesos que lancen usuarios sin Commissions_LDR.
- Riesgo ROJO confirmado: el código se ejecuta dentro de la transacción de registro de ventas; un error en la codeunit (incluido uno de permisos) impide registrar facturas y abonos.

### Reparto de tareas
Al aprobar la tarea, cada fila se crea como sub-issue en GitHub.

| Tarea | Descripción | Depende de | Hecho cuando |
| --- | --- | --- | --- |
| T-01 | P1: revisar y cuestionar las decisiones P-1 a P-6 con el consultor | — | Decisiones confirmadas o cambiadas por escrito |
| T-02 | Enum, tabla Commission Entry_LDR con claves y lista no editable con Navegar | T-01 | Compila; la lista no permite crear, modificar ni borrar |
| T-03 | Extensiones de producto y vendedor (campo, FlowField y DrillDown) | T-02 | Pasan A-1 y A-2 |
| T-04 | Commission Mgt._LDR y suscriptores de Sales-Post | T-03 | Pasan A-3 a A-9 |
| T-05 | Suscriptores de Navigate | T-04 | Pasa A-10 |
| T-06 | PermissionSet, PermissionSetExtension de D365 SALES DOC, POST, traducciones y documentación técnica (solución, eventos y por qué, funciones, capturas, dudas) | T-05 | Pasa A-11; XLIFF completo y documento de entrega con capturas |

## 3. Documentación técnica del desarrollo realizado

_Pendiente del técnico._

## 4. Guion de pruebas funcional key-user

Pruebas que valida el consultor en un entorno sandbox con CRONUS ES (divisa local EUR, precisión de importes 0,01).

### Parametrización previa
- Vendedor «PS» con «% Comisión» 5; vendedor «JR» con «% Comisión» 0.
- Cliente 10000 con vendedor PS; cliente 20000 sin vendedor; cliente 30000 con vendedor JR; cliente 40000 en USD con vendedor PS.
- Producto 1896-S sin exclusión; producto 1900-S sin exclusión; producto «PORTES» con «Excluir de comisión» activo.
- Divisa USD con factor de divisa 1,10 en la fecha de prueba.
- Usuario de prueba sin SUPER, con los conjuntos estándar de ventas (incluido D365 SALES DOC, POST) y sin Commissions_LDR.

### Escenarios de prueba
| Prueba | Requisito | Escenario | Resultado esperado | OK |
| --- | --- | --- | --- | --- |
| A-1 | RF-1.1 | Abrir la ficha del vendedor PS | Se ve «% Comisión» = 5 y «Comisión pendiente (DL)» = 0,00 |  |
| A-2 | RF-1.2 | Abrir la ficha del producto PORTES y la del 1896-S | PORTES tiene «Excluir de comisión» marcado; 1896-S, no |  |
| A-3 | RF-3.1, RF-2.1 | Factura al cliente 10000: 10 × 100 € de 1896-S, 2 × 250 € de 1900-S, 1 línea de cuenta de 200 € y 1 × 50 € de PORTES; registrar | 2 movimientos: base 1.000,00 / comisión 50,00 y base 500,00 / comisión 25,00, con % 5, tipo Factura, nº y línea de la factura, cliente, producto y usuario |  |
| A-4 | RF-3.2, RF-2.3 | Abono al cliente 10000 de 10 × 100 € de 1896-S; registrar y abrir la ficha de PS | 1 movimiento: base −1.000,00, comisión −50,00, tipo Abono. «Comisión pendiente (DL)» pasa de 75,00 a 25,00 y al pulsarla se ven los 3 movimientos |  |
| A-5 | RF-3.3 | Registrar una factura de 1 × 100 € de 1896-S al cliente 20000 (sin vendedor) y otra al 30000 (vendedor JR, 0 %) | Ambas se registran sin error y no se crea ningún movimiento |  |
| A-6 | RF-3.4 | Factura al cliente 40000 en USD: 1 × 1.000,00 USD de 1896-S, factor 1,10; registrar | Movimiento con base 909,09 € y comisión 45,45 € |  |
| A-7 | RF-3.1 | Pedido al cliente 10000 de 10 × 100 € de 1896-S; registrar envío de 10 y facturar 4; después facturar las 6 restantes | El envío no crea movimiento; primera factura: base 400,00 / comisión 20,00; segunda: base 600,00 / comisión 30,00 |  |
| A-8 | RF-3.1 | Vista previa de registro de una factura de 1 × 100 € de 1896-S al cliente 10000 | La vista previa se muestra sin movimientos de comisión y, al cerrarla, no hay ningún movimiento nuevo en la lista |  |
| A-9 | RF-2.2 | En la lista de movimientos, intentar crear, modificar o borrar un movimiento | No está permitido; la acción «Navegar» abre Navegar con la fecha y el nº del documento |  |
| A-10 | RF-4.1 | Desde la factura registrada de A-3, pulsar «Navegar» | Aparece la línea de movimientos de comisión con 2 registros; al pulsarla se abren esos 2 movimientos |  |
| A-11 | RF-3.1 | Con el usuario sin Commissions_LDR, registrar una factura de 1 × 100 € de 1896-S al cliente 10000 y pulsar «Navegar» desde ella | La factura se registra sin error de permisos y el movimiento existe (se comprueba con un usuario con Commissions_LDR); en Navegar ese usuario no ve la línea de comisiones |  |

## Fuentes
- Tarea de formación TF0020 – Comisiones de vendedores (Bloque 5); reparto del Bloque 5 (TF0020-TF0023).
- BC 29 ES: Sales/Posting/SalesPost.Codeunit.al (eventos de línea, Commit previo a OnAfterPostSalesDoc en la línea 407); Foundation/Navigate/Navigate.Page.al (SetDoc, eventos); Foundation/Navigate/DocumentEntry.Table.al (InsertIntoDocEntry); Finance/Currency/CurrencyExchangeRate.Table.al (ExchangeAmtFCYToLCY); CRM/Team/SalespersonPurchaser.Table.al y SalespersonPurchaserCard.Page.al; Finance/GeneralLedger/Preview/PostingPreviewEventHandler.Codeunit.al.
- https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-events-in-al
- https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-autoincrement-property
- Referencias LiderIT: kassandra (informe de comisiones de vendedores), como contraste funcional.
- bc-code-intel find_bc_knowledge (redactor): «AL Event Subscriber Architecture» (suscriptores finos, lógica en codeunit); sin normas ni lecciones de la capa LiderIT sobre movimientos propios o comisiones.
- BC 28 frente a 29 (bc-observatory bc_diff_object): Sales-Post (80) y Navigate (344); firmas de los eventos de la codeunit 80 (PreviewMode solo en OnAfterSalesInvLineInsert); Gen. Jnl.-Post Preview (19), IsActive; DocumentEntry.Table.al:107 (InsertIntoDocEntry); Navigate.Page.al:58 (SourceTableTemporary).
- Revisado con bc-code-intel (especialistas: sam-coder; find_bc_knowledge seth-security «Permission Set Design Patterns»). Respuestas genéricas, sin normas ni lecciones LiderIT sobre permisos indirectos en registro; P-1, P-4 y P-6 las decide el revisor.

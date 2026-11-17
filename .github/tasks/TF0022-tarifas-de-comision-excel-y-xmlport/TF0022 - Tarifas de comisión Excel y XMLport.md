# Tarea de desarrollo TF0022 — Tarifas de comisión Excel y XMLport

Código ERPIT: pendiente · Código en el origen: TF0022
Cliente: LiderIT · Fecha: 17/11/2026 · Proyecto: Formación – Bloque 5 (Eventos, registro y procesos) · Consultor: Alejandro González Torres
Origen: Tarea de formación TF0022 (apartado del Bloque 5), continuación de TF0020 y TF0021 · Riesgo: AMARILLO (tabla y lógica nuevas acotadas; cambia el cálculo del % de comisión de TF0020; no toca contabilidad, IVA ni almacén) · Estado: Borrador · Puntos a validar pendientes: 10 (0 bloqueantes)

## 1. Descripción funcional

### Contexto
Continuación de TF0020 y TF0021. Dirección comercial negocia porcentajes distintos por vendedor y categoría de producto (por ejemplo, 8 % en mobiliario y 3 % en accesorios), los prepara en Excel y quiere cargarlos en BC en lugar de teclearlos. Nóminas necesita los movimientos de comisión de un periodo en Excel, para cuadrarlos a mano, y en un CSV de formato fijo para su programa de nóminas.

### Situación actual
Tras TF0020 cada vendedor tiene un único «% Comisión» en su ficha, que se aplica a todas sus ventas. Los movimientos de comisión se consultan en la lista «Commission Entries» sin exportación propia; solo está el «Abrir en Excel» estándar de la lista.

### Alcance
1. **Tarifas por vendedor y categoría**
   - RF-1.1 Tabla de tarifas por vendedor y categoría de producto, con porcentaje entre 0 y 100 y fecha de inicio opcional. Categoría en blanco = cualquier categoría.
   - RF-1.2 Lista editable de tarifas, accesible desde la ficha del vendedor (filtrada por él) y desde el buscador.
2. **Cálculo del % de comisión**
   - RF-2.1 El % de cada línea se busca por este orden: tarifa de vendedor y categoría (la más reciente con fecha de inicio igual o anterior a la fecha de registro); tarifa del vendedor con categoría en blanco; «% Comisión» de la ficha del vendedor.
   - RF-2.2 No se duplica código: la función de TF0020 que crea el movimiento solo cambia la forma de obtener el %.
3. **Importar tarifas desde Excel**
   - RF-3.1 Acción «Importar desde Excel» en la lista de tarifas, con fichero de cuatro columnas (vendedor, categoría, % comisión, fecha inicio) y cabeceras en la fila 1.
   - RF-3.2 Cada fila se valida (vendedor y categoría existentes, % numérico entre 0 y 100, fecha válida). Las correctas insertan o modifican la tarifa; las erróneas se guardan con nº de fila y motivo y la importación sigue.
   - RF-3.3 Al terminar se informa de filas importadas, modificadas y con error; si hay errores, se abre la lista de errores.
4. **Exportar movimientos a Excel**
   - RF-4.1 Acción «Exportar a Excel» en la lista «Commission Entries» con los filtros que tenga aplicados el usuario.
   - RF-4.2 Columnas: fecha de registro, tipo y nº de documento, vendedor, nombre del vendedor, cliente, nombre del cliente, base, %, comisión, liquidado y nº de liquidación, con cabecera en negrita e importes con formato numérico.
5. **Exportar fichero CSV para nóminas**
   - RF-5.1 Acción «Exportar fichero nóminas» en la misma lista, con los mismos movimientos filtrados, mediante el XMLport «Commission Payroll Export» (texto variable, separador «;», sin delimitador, UTF-8).
   - RF-5.2 Primera fila con cabeceras y columnas en este orden: código de vendedor, nombre de vendedor, fecha de registro (AAAAMMDD), nº de documento e importe de comisión con 2 decimales y punto decimal.
   - RF-5.3 El fichero se descarga con el nombre COMISIONES_AAAAMM.csv.
6. **Comparativa y documentación técnica**
   - RF-6.1 La documentación de entrega explica por qué se importa con Excel Buffer y no con XMLport, qué ventajas tiene el XMLport para nóminas y en qué se diferencia la exportación a Excel del «Abrir en Excel» estándar.
   - RF-6.2 La entrega incluye explicación de la solución, lectura del Excel Buffer, estructura del XMLport, funciones de la codeunit, capturas de código y de funcionamiento (Excel de entrada, Excel y CSV de salida) y problemas o dudas encontrados.

### Puntos a validar

**Para el cliente**

| # | Tipo | Punto | Bloquea | Responde | Estado |
| --- | --- | --- | --- | --- | --- |
| P-5 | Pregunta | Cabeceras exactas del CSV de nóminas, presencia o no de BOM en el UTF-8 y si el programa de nóminas admite nombres con tildes. Propuesta: cabeceras en inglés sin espacios (SalespersonCode, SalespersonName, PostingDate, DocumentNo, CommissionAmount), escritas como textos fijos en una primera fila (el XMLport de texto no tiene propiedad para sacar nombres de campo), UTF-8 sin BOM. | No | Nóminas (LiderIT) | Pendiente |
| P-9 | Fuera de alcance | Exportar tarifas a Excel, plantilla Excel descargable, importar tarifas desde CSV o XML, importar movimientos, programar la exportación en cola de trabajos (TF0023) y permisos distintos del conjunto «Commissions». | No | Dirección comercial (LiderIT) | Pendiente |

**Internos (LiderIT)**

| # | Tipo | Punto | Bloquea | Responde | Estado / respuesta |
| --- | --- | --- | --- | --- | --- |
| P-1 | Supuesto | Decisión (validada en revisión): clave de tres campos (vendedor, categoría y fecha de inicio; fecha en blanco = siempre). El origen fija la clave en vendedor y categoría, pero pide «la tarifa más reciente con fecha de inicio igual o anterior a la de registro», lo que exige varias filas por pareja; con dos campos una tarifa nueva machacaría la anterior y no habría histórico. Categoría y fecha en blanco son válidas en la clave. La búsqueda filtra vendedor y categoría, SetRange(«Starting Date», 0D, fecha) y toma el último registro de la clave (FindLast), sin ordenar aparte. El programador la cuestiona en P1. | No | Consultor LiderIT | Pendiente |
| P-2 | Supuesto | La categoría se lee de «Item Category Code» de la ficha del producto de la línea (no se hereda de la categoría padre). Si el producto no tiene categoría, se usa la tarifa del vendedor con categoría en blanco y, si no existe, el % de la ficha. Cambio sobre TF0020: la condición «% del vendedor distinto de 0» pasa a «% devuelto por GetCommissionPct distinto de 0», porque una tarifa puede dar un % aunque la ficha tenga 0; una tarifa con 0 % no genera movimiento. Las líneas excluidas de comisión siguen lo definido en TF0020. | No | Consultor LiderIT | Pendiente |
| P-3 | Supuesto | Lectura de celdas: se lee el texto de cada celda y se interpreta con Evaluate según la configuración regional del usuario (coma decimal y fecha dd/mm/aaaa en un BC en español). Si la celda de fecha llega como número de serie de Excel, también se acepta. Una fila repetida (misma clave) dentro del mismo fichero prevalece la última. | No | Consultor LiderIT | Pendiente |
| P-4 | Supuesto | La importación no es todo o nada: cada fila se procesa de forma independiente y las erróneas no deshacen las correctas. Una fila cuya clave ya existe cuenta como «modificada», aunque el % sea el mismo. | No | Consultor LiderIT | Pendiente |
| P-6 | Supuesto | AAAAMM del nombre del fichero: año y mes de la «Posting Date» más reciente de los movimientos filtrados (SetCurrentKey por fecha y FindLast), no de la fecha de hoy ni del filtro: así no hay que interpretar filtros complejos y el nombre refleja lo exportado. Un «;» dentro del nombre del vendedor se sustituye por «,» para no romper el CSV (sin delimitador de texto no hay otra forma de protegerlo). | No | Consultor LiderIT | Pendiente |
| P-7 | Supuesto | La exportación a Excel con Excel Buffer carga todo el conjunto en una tabla temporal y en memoria. Es válida para el volumen de un periodo de comisiones; si crece a decenas de miles de movimientos, el CSV (XMLport, que escribe en flujo) es la vía. Se avisa si el filtro supera un límite razonable (propuesta: 20.000 filas) y no se exporta sin confirmar. Si el filtro no devuelve movimientos, se avisa y no se genera fichero. | No | Consultor LiderIT | Pendiente |
| P-8 | Supuesto | Los nombres de vendedor y cliente no se guardan en el movimiento (TF0020); se buscan en sus tablas al exportar. Campos de «Commission Entry_LDR» usados, tal como están en TF0020 y TF0021: Posting Date, Document Type (enum «Commission Document Type_LDR»), Document No., Salesperson Code, Customer No., Base Amount (LCY), Commission %, Commission Amount (LCY), Liquidated y Liquidation No. La extensión de página de la ficha del vendedor se llama «Salesperson/Purchaser_LDR» (nombre de TF0020; TF0021 la llama «Salesperson/Purchaser Card_LDR», a unificar). | No | Programador LiderIT | Pendiente |
| P-10 | Supuesto | La app declara application 28 y el estándar consultado es BC 29. Las funciones de Excel Buffer usadas existen en ambos, pero hay que verificarlas en 28 si se publica allí. | No | Programador LiderIT | Pendiente |

## 2. Descripción desarrollo

Se añade una tabla de tarifas con su lista, se cambia la forma de obtener el % en la codeunit de TF0020 y se crean la importación desde Excel y las dos exportaciones. Se realizarán las siguientes modificaciones:

### 1. Tarifas por vendedor y categoría
**Ubicación:** Tabla Salesperson/Purchaser (13), Página Salesperson/Purchaser Card (5116), Tabla Item Category (5722).
Se crea la tabla «Commission Rate» con la clave propuesta en P-1. Las dos relaciones usan TableRelation, y la categoría en blanco significa «cualquier categoría».

La página lista editable «Commission Rates» se abre desde una acción nueva «Tarifas de comisión» en la ficha del vendedor (filtrada por él) y se puede buscar por nombre. Contiene las acciones de importación del bloque 3. La acción se añade en la extensión de página de la ficha creada en TF0020.

| Campo | Tipo | Comentario |
| --- | --- | --- |
| Salesperson Code | Code[20] | Clave 1. Relación con Salesperson/Purchaser |
| Item Category Code | Code[20] | Clave 2. Relación con Item Category. En blanco = cualquier categoría |
| Starting Date | Date | Clave 3 (P-1). Opcional: en blanco aplica siempre |
| Commission % | Decimal | MinValue 0, MaxValue 100, DecimalPlaces 0:5 |


### 2. Cálculo del % de comisión
**Ubicación:** Codeunit «Commission Mgt._LDR» (TF0020), Tabla Item (27), Tabla Item Category (5722).
Se añade a la codeunit de TF0020 la función GetCommissionPct(Salesperson, ItemCategory, PostingDate): primero busca la tarifa del vendedor y la categoría con Starting Date <= fecha de registro y la más reciente (SetRange hasta la fecha y FindLast, ya que la clave termina en la fecha); si no hay, repite con categoría en blanco; si no hay, devuelve el «% Comisión» de la ficha del vendedor. La categoría la lee de «Item Category Code» del producto (SetLoadFields).

La función de TF0020 que crea el movimiento solo cambia la obtención del %: llama a GetCommissionPct y la condición de crear movimiento pasa a «% obtenido distinto de 0» (P-2). Los movimientos ya creados no se recalculan.


### 3. Importar tarifas desde Excel
**Ubicación:** Página «Commission Rates»; tabla Excel Buffer (370).
La acción «Importar desde Excel» llama a una codeunit nueva, no a la página. Sube el fichero con UploadIntoStream, elige la hoja con SelectSheetsNameStream, la abre con OpenBookStream y la lee con ReadSheet. Se usa Excel Buffer porque un XMLport solo lee XML o texto delimitado, nunca un .xlsx (bloque 6).

Las celdas se recorren ordenadas por «Row No.», agrupando las de cada fila y saltando la primera. Cada fila se valida y, si es correcta, se inserta o modifica la tarifa; si no, se añade a una tabla temporal de errores y se sigue (P-3, P-4). Al final se muestra el mensaje y, si hay errores, la lista de errores.

| Columna | Contenido | Validación |
| --- | --- | --- |
| A | Vendedor | Obligatorio; debe existir en Salesperson/Purchaser |
| B | Categoría | Opcional; si viene, debe existir en Item Category |
| C | % Comisión | Obligatorio; numérico (Evaluate) entre 0 y 100 |
| D | Fecha inicio | Opcional; fecha válida (Evaluate) |

- Tabla temporal «Commission Import Error»: nº de fila, texto de la fila y motivo.
- Si la hoja no tiene datos tras la cabecera o el fichero no se puede abrir, se muestra un error y no se modifica nada.
- Mensaje: “Importación terminada. Filas importadas: %1. Modificadas: %2. Con error: %3.”
- Mensaje: “El vendedor %1 no existe.”
- Mensaje: “El porcentaje debe estar entre 0 y 100.”

### 4. Exportar movimientos a Excel
**Ubicación:** Página «Commission Entries» (TF0020), tabla Excel Buffer (370).
La acción «Exportar a Excel» pasa los registros de la página con sus filtros (Rec) a una función de «Commission Mgt._LDR». Esta construye el libro con Excel Buffer: NewRow y AddColumn con cabecera en negrita e importes con formato numérico, y después CreateNewBook, WriteSheet, CloseBook, SetFriendlyFilename y OpenExcel.

Los nombres de vendedor y cliente se buscan al escribir cada fila. Las fechas se escriben como fecha, no como texto. Son 12 columnas, con tipo y nº de documento en columnas separadas. Antes de exportar se aplican los avisos de P-7 (sin movimientos o más de 20.000).

| Columna | Origen |
| --- | --- |
| 1 Fecha registro | Posting Date |
| 2 Tipo documento, 3 Nº documento | Document Type y Document No. |
| 4 Vendedor, 5 Nombre vendedor | Salesperson Code y nombre de Salesperson/Purchaser |
| 6 Cliente, 7 Nombre cliente | Customer No. y nombre de Customer |
| 8 Base, 9 %, 10 Comisión | Base Amount (LCY), Commission % y Commission Amount (LCY); formato #,##0.00 en importes |
| 11 Liquidado, 12 Nº liquidación | Liquidated y Liquidation No. (TF0021) |


### 5. Exportar fichero CSV para nóminas
**Ubicación:** Página «Commission Entries» (TF0020); XMLport nuevo.
El XMLport «Commission Payroll Export» se configura con Direction = Export, Format = VariableText, FieldSeparator = ';', FieldDelimiter = '' (sin comillas) y TextEncoding = UTF8. Tiene un solo elemento de tabla, «Commission Entry», y sus columnas en el orden del requisito.

Fila de títulos: la propiedad FirstLineHasFieldNames no existe en los XMLport de AL (no figura entre las propiedades de XMLport de Microsoft Learn), así que no se usa.

Se añade, antes del elemento de movimientos, un elemento de tabla «Header» sobre Integer con SourceTableView = Number 1, cuyos cinco elementos de texto se rellenan en su OnAfterGetRecord con las cabeceras de P-5; el elemento de movimientos va después en el mismo nivel y ambos salen separados por el salto de línea. Así la cabecera sale una sola vez y con el mismo separador que los datos.

El nombre del vendedor y los valores formateados salen de elementos de texto rellenados en OnAfterGetRecord del elemento de tabla, que busca el vendedor y sustituye «;» por «,». La fecha se formatea con '<Year4><Month,2><Day,2>'.

El importe se formatea con Format(Importe, 0, '<Precision,2:2><Standard Format,9>'): la sintaxis es válida (Precision y Standard Format son atributos combinables y el formato 9 es el XML, con punto), pero la combinación con el 9 no está documentada y debe comprobarse en BC; alternativa determinista: pasar el importe a céntimos enteros con Round(Importe * 100, 1) e insertar el punto en el texto.

| Posición | Nodo | Valor |
| --- | --- | --- |
| Fila 1 (elemento Header) | Textos fijos | SalespersonCode;SalespersonName;PostingDate;DocumentNo;CommissionAmount |
| 1 | SalespersonCode | Código de vendedor |
| 2 | SalespersonName | Nombre del vendedor (texto) |
| 3 | PostingDate | AAAAMMDD (texto) |
| 4 | DocumentNo | Nº de documento |
| 5 | CommissionAmount | Commission Amount (LCY) con 2 decimales y punto (texto) |

- La acción crea el XMLport en una variable, le pasa los filtros con SetTableView, fija UseRequestPage = false, lo ejecuta contra un OutStream de un TempBlob con SetDestination y Export, y descarga el flujo con DownloadFromStream.
- Nombre del fichero: COMISIONES_AAAAMM.csv según P-6.

### 6. Comparativa y documentación técnica
**Ubicación:** Documentación de entrega de la tarea.
Importación con Excel Buffer y no con XMLport: un XMLport solo lee XML o texto delimitado/fijo. Un .xlsx es un ZIP con XML interno, así que solo Excel Buffer lo abre, elige hoja y entrega celda a celda. Dirección trabaja en Excel; pedirle un CSV añadiría un paso manual y fallos de formato.

XMLport para nóminas: formato exacto y repetible (separador, sin delimitador, codificación, AAAAMMDD, decimales), escritura en flujo sin cargar todo en memoria, sin depender de Excel en el equipo del usuario y reutilizable en una cola de trabajos (TF0023). Excel Buffer sirve para ficheros que una persona revisa o formatea, o que hay que leer desde .xlsx. Regla de proyecto: .xlsx de entrada o de revisión = Excel Buffer; fichero máquina a máquina con formato fijo o volumen = XMLport.

Frente al «Abrir en Excel» estándar: el estándar vuelca las columnas de la página tal como estén (personalización del usuario incluida) y no añade nombres de vendedor ni cliente, ni da control de columnas, orden, formato o nombre del fichero. Tiene sentido desarrollarla cuando se necesita un formato fijo y estable para un proceso (cuadre con nóminas); para una consulta puntual basta el estándar. La opción propuesta es mantenerla porque nóminas cuadra siempre con las mismas columnas (P-7 limita su volumen).

- Se entrega un documento con las secciones del RF-6.2 y las capturas (Excel de entrada, Excel y CSV de salida).

### Alcance técnico
- Table 50003 «Commission Rate_LDR»: tarifas por vendedor, categoría y fecha de inicio
- Page 50004 «Commission Rates_LDR»: lista editable de tarifas con acción «Importar desde Excel»
- Codeunit 50005 «Commission Rate Import_LDR»: importación desde Excel con Excel Buffer y validación por fila
- Table 50004 «Commission Import Error_LDR»: tabla temporal de errores de importación (nº de fila y motivo)
- Page 50005 «Commission Import Errors_LDR»: lista de solo lectura de la tabla temporal de errores
- XMLport 50000 «Commission Payroll Export_LDR»: CSV para nóminas, con elemento de cabecera de textos fijos
- Codeunit 50000 «Commission Mgt._LDR»: objeto de TF0020: se añaden GetCommissionPct y la exportación a Excel, y se cambia la obtención del % y la condición de crear movimiento
- Page 50000 «Commission Entries_LDR»: objeto de TF0020: dos acciones nuevas, «Exportar a Excel» y «Exportar fichero nóminas»
- PageExtension 50002 «Salesperson/Purchaser_LDR» (extiende página Salesperson/Purchaser Card (5116)): acción «Tarifas de comisión»; es la extensión de la ficha creada en TF0020 (mismo nombre que allí)
- PermissionSet 50000 «Commissions_LDR»: objeto de TF0020: se añaden los objetos de esta tarea
- Codeunit 50006 «Commission Rates Test_LDR»: tests automáticos (app de test)
- Sin suscripciones a eventos nuevas: el cambio de cálculo es una llamada dentro de la codeunit de TF0020, no un evento.
- Funciones de Excel Buffer verificadas en BC 29 ES (ExcelBuffer.Table.al): CreateNewBook, OpenBookStream, SelectSheetsNameStream, ReadSheet, WriteSheet, CloseBook, NewRow, AddColumn, SetFriendlyFilename y OpenExcel. UploadIntoStream y DownloadFromStream son métodos del sistema. XMLport: FirstLineHasFieldNames no existe (Microsoft Learn); la cabecera es un elemento de tabla de textos fijos.
- Captions en inglés con Comment = 'ESP="..."' y textos de mensajes en Labels.

### Consideraciones
- Depende de TF0020 (codeunit «Commission Mgt._LDR» y tabla/página de movimientos) y de TF0021 (campos Liquidated y Liquidation No.). Esta tarea se desarrolla después y amplía esos objetos, no los crea.
- El cambio del % solo afecta a los movimientos nuevos; los ya registrados conservan su %.
- Importación: el fichero se lee entero en el Excel Buffer (tabla temporal); no es apto para cargas masivas.
- Sin parámetros de configuración nuevos: no se crea tabla de configuración.
- Datos de prueba con CRONUS; ningún dato real.
- Los ejercicios del origen (fila de títulos en un XMLport, comparativa, diferencia con «Abrir en Excel») están resueltos en este documento con su justificación. En sdd-implementar el programador debe cuestionarlos en P1; a comprobar en BC: el formato '<Precision,2:2><Standard Format,9>' y el elemento Header del XMLport.
- Cambio en TF0020: la condición de crear movimiento usa el % de GetCommissionPct y no el de la ficha (P-2).
- Nombres de nodos del XMLport sin espacios ni tildes.

### Reparto de tareas
Al aprobar la tarea, cada fila se crea como sub-issue en GitHub.

| Tarea | Descripción | Depende de | Hecho cuando |
| --- | --- | --- | --- |
| T-01 | Tabla «Commission Rate» y página lista, acción en la ficha del vendedor | TF0020 | Compila y se crean tarifas con validación 0-100 y relaciones |
| T-02 | GetCommissionPct y cambio en la función de creación del movimiento | T-01 | Pasan A-3 a A-6 |
| T-03 | Importación desde Excel con tabla y página de errores | T-01 | Pasan A-7 a A-9 |
| T-04 | Exportar a Excel desde la lista de movimientos | TF0021 | Pasan A-10 y A-11 |
| T-05 | XMLport de nóminas y acción de exportación | TF0021 | Pasan A-12 a A-16 |
| T-06 | Tests automáticos, permission set y traducciones es-ES | T-02, T-03, T-04, T-05 | Tests en verde (incluye el límite de 20.000 del A-18) y XLIFF completo |
| T-07 | Documentación técnica con comparativa y capturas | T-04, T-05 | Contiene todo lo del RF-6.2 |

## 3. Documentación técnica del desarrollo realizado

_Pendiente del técnico._

## 4. Guion de pruebas funcional key-user

Pruebas que valida el consultor en un entorno de pruebas con datos de CRONUS, con TF0020 y TF0021 ya instaladas.

### Parametrización previa
- Vendedores JR (con «% Comisión» 5 en la ficha), PS (con 2) y BD (con 2 y sin ninguna tarifa); categorías de producto MOBILIARIO y ACCESORIOS con un producto de cada una, y un producto sin categoría. Tabla de tarifas vacía al empezar cada escenario de importación (A-7 y A-9).
- Fichero Excel «tarifas.xlsx» con cabeceras en la fila 1 y filas: JR / MOBILIARIO / 8 / 01/01/2027; JR / ACCESORIOS / 3 / (vacía); JR / (vacía) / 4 / (vacía); PS / MOBILIARIO / 7 / (vacía); PS / ACCESORIOS / 2,5 / (vacía).
- Fichero «errores.xlsx» con cabeceras y filas: XX / MOBILIARIO / 8; JR / MOBILIARIO / 150; JR / ACCESORIOS / abc; PS / MOBILIARIO / 6 / (vacía).

### Escenarios de prueba
| Prueba | Requisito | Escenario | Resultado esperado | OK |
| --- | --- | --- | --- | --- |
| A-1 | RF-1.1 | Crear una tarifa JR / MOBILIARIO / 8 % sin fecha. Intentar otra con 101 % y otra con el vendedor XX. Borrar la primera al terminar | La primera se guarda; el 101 % y el vendedor inexistente dan error de validación y no se guardan |  |
| A-2 | RF-1.2 | Abrir «Tarifas de comisión» desde la ficha de JR y desde el buscador | Desde la ficha solo salen las tarifas de JR; desde el buscador salen todas |  |
| A-3 | RF-2.1 | Con las tarifas de «tarifas.xlsx» importadas (A-7), registrar el 15/01/2027 una factura de JR con 1.000 € de producto MOBILIARIO y 200 € de ACCESORIOS | Dos movimientos: base 1.000,00 € al 8 % = 80,00 € y base 200,00 € al 3 % = 6,00 € |  |
| A-4 | RF-2.1 | Registrar el 15/12/2026 la misma factura de MOBILIARIO de JR (antes de la fecha de inicio de la tarifa del 8 %) | Se aplica la tarifa de categoría en blanco: 1.000,00 € al 4 % = 40,00 € |  |
| A-5 | RF-2.1 | Registrar una factura de JR de un producto sin categoría por 500 € y otra del vendedor BD (sin tarifas, 2 % en la ficha) por 500 € | JR: 4 % (tarifa en blanco) = 20,00 €. BD: 2 % de la ficha = 10,00 € |  |
| A-6 | RF-2.2 | Revisar el código de la función que crea el movimiento tras el cambio | Solo cambia la obtención del %: sin lógica de creación duplicada |  |
| A-7 | RF-3.1, RF-3.3 | Con la tabla de tarifas vacía, importar «tarifas.xlsx» (5 filas) | Mensaje «Filas importadas: 5. Modificadas: 0. Con error: 0» y 5 tarifas en la lista; la fila de cabeceras no se importa |  |
| A-8 | RF-3.2 | Cambiar en el Excel el % de JR / MOBILIARIO de 8 a 9 y reimportar | Siguen 5 tarifas, sin duplicados; la de JR / MOBILIARIO pasa a 9 %. Mensaje «Filas importadas: 0. Modificadas: 5. Con error: 0» (P-4) |  |
| A-9 | RF-3.2, RF-3.3 | Con la tabla de tarifas vacía, importar «errores.xlsx» | Mensaje «Filas importadas: 1. Modificadas: 0. Con error: 3». Se importa la fila de PS (6 %); se abre la lista con 3 errores: fila 2 vendedor XX inexistente, fila 3 % de 150 fuera de rango, fila 4 % «abc» no numérico |  |
| A-10 | RF-4.1 | En «Commission Entries» filtrar por vendedor JR y pulsar «Exportar a Excel» | El Excel solo contiene los movimientos de JR; sin filtro, todos |  |
| A-11 | RF-4.2 | Abrir el Excel exportado con los movimientos de A-3 | Las 12 columnas en orden con nombres de vendedor y cliente; cabecera en negrita; la fila de 1.000,00 € muestra base 1.000,00, % 8 y comisión 80,00 con formato numérico |  |
| A-12 | RF-5.1 | Filtrar por JR y pulsar «Exportar fichero nóminas»; abrir el CSV con el Bloc de notas | Solo movimientos de JR, separados por «;», sin comillas |  |
| A-13 | RF-5.2 | Revisar el contenido del CSV de A-12 | Primera línea con las cabeceras SalespersonCode;SalespersonName;PostingDate;DocumentNo;CommissionAmount; las líneas de A-3 salen como JR;<nombre>;20270115;<nº documento>;80.00 y ...;6.00 (fecha AAAAMMDD, punto decimal y 2 decimales) |  |
| A-14 | RF-5.3 | Con filtro de vendedor JR, exportar con fecha de registro 01/01/2027..31/01/2027 y otra vez con 01/12/2026..31/12/2026 (movimiento de A-4) | Los ficheros se llaman COMISIONES_202701.csv y COMISIONES_202612.csv (mes de la fecha de registro más reciente exportada, P-6) |  |
| A-15 | RF-5.1 | Cambiar el nombre de un vendedor a «Pérez; Gómez» y exportar sus movimientos | En el CSV el nombre sale como «Pérez, Gómez» (sin «;» interno) y las columnas siguen alineadas |  |
| A-16 | RF-5.1, RF-4.1 | Filtrar por un vendedor sin movimientos y exportar con las dos opciones | Aviso de que no hay movimientos a exportar y no se genera Excel ni CSV con solo cabeceras |  |
| A-17 | RF-6.1, RF-6.2 | Revisar el documento de entrega | Contiene las tres respuestas de la comparativa y todos los apartados de RF-6.2 con capturas |  |
| A-18 | RF-4.1 | Test automático: exportar a Excel con 20.001 movimientos filtrados | Pide confirmación antes de exportar; si el usuario no confirma, no se genera el fichero (P-7) |  |

## Fuentes
- Tarea de formación TF0022 (apartado del origen); reparto del Bloque 5 (reparto.md).
- BC 29 ES: System/DataExchange/ExcelBuffer.Table.al (funciones y campos Row No., Column No., Cell Value as Text, Cell Type); CRM/Team/SalespersonPurchaser.Table.al (13) y SalespersonPurchaserCard.Page.al (5116); Inventory/Item/ItemCategory.Table.al (5722).
- Microsoft Learn: propiedades de XMLport (devenv-xmlport-properties; no existe FirstLineHasFieldNames), Format Property de XMLport (VariableText) y «Formatting values, dates, and time» (atributos Precision y Standard Format; formato 9 = XML). La combinación Precision + Standard Format 9 no figura en ejemplos: [Verificar en BC].
- Revisado con bc-code-intel (especialistas: sam-coder; ask_bc_expert sobre XMLport VariableText, formato decimal y Excel Buffer): devolvió solo el perfil del especialista, sin normas de LiderIT específicas; la verificación se hizo en Microsoft Learn y en el estándar local.

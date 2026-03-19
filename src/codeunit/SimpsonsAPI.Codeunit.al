// =============================================================================
// CODEUNIT: Simpsons API
// OBJETO: Codeunit 50004
// =============================================================================
// Propósito:
//   Este codeunit centraliza TODA la comunicación con la API de los Simpsons.
//   Contiene dos grupos de funcionalidad:
//     1) Procedimientos PÚBLICOS: llamados desde las páginas de BC.
//     2) Procedimientos LOCALES (privados): lógica interna de HTTP y JSON.
//
// URL base de la API: https://thesimpsonsapi.com/api
// Documentación:      https://thesimpsonsapi.com/#docs
//
// ─────────────────────────────────────────────────────────────────────────────
// CONCEPTOS CLAVE QUE SE EXPLICAN EN ESTE FICHERO:
//   A) Cómo hacer una llamada HTTP GET en AL (HttpClient)
//   B) Cómo leer y parsear JSON en AL (JsonObject, JsonArray, JsonToken, JsonValue)
//   C) Cómo manejar valores null en JSON
//   D) Cómo iterar un array JSON
//   E) Paginación de APIs REST
// =============================================================================

codeunit 50004 "Simpsons API"
{
  // ===========================================================================
  // SECCIÓN A: CONSTANTES INTERNAS
  // ===========================================================================
  // Definimos las URLs base como variables locales de procedimiento en vez de
  // constantes globales para evitar problemas de estado en ejecuciones paralelas.

  // ═══════════════════════════════════════════════════════════════════════════
  // PROCEDIMIENTO PÚBLICO 1: ImportarPersonajes
  // ═══════════════════════════════════════════════════════════════════════════
  /// <summary>
  /// Descarga los personajes de los Simpsons desde la API (primeras 3 páginas,
  /// 60 personajes) y los guarda en la tabla Characters de BC.
  /// </summary>
  /// <param name="Characters">Tabla destino donde se guardarán los personajes.</param>
  procedure ImportarPersonajes(var Characters: Record Characters)
  var
    // ─── Variables para HTTP ───────────────────────────────────────────────
    ResponseText: Text;         // Texto completo de la respuesta JSON de la API
    ApiUrl: Text;               // URL que llamaremos en cada página de resultados

    // ─── Variables para parsear JSON ───────────────────────────────────────
    // En AL, el JSON se parsea con estos 4 tipos de datos:
    //   JsonObject  → Representa un objeto JSON: { "clave": valor }
    //   JsonArray   → Representa un array JSON:  [ elem1, elem2, ... ]
    //   JsonToken   → Tipo genérico que puede contener Object, Array o Value
    //   JsonValue   → Valor simple: texto, número, booleano o null
    JsonObj: JsonObject;        // El objeto raíz de la respuesta
    JsonArr: JsonArray;         // El array "results" con los personajes
    JsonToken: JsonToken;       // Token genérico para leer campos
    NextToken: JsonToken;       // Para verificar si hay siguiente página
    CharJson: JsonObject;       // Objeto JSON de cada personaje individual

    // ─── Variables de control de paginación ───────────────────────────────
    // La API devuelve los resultados paginados: 20 personajes por página.
    // Para cargar más, hay que llamar a ?page=2, ?page=3, etc.
    // La respuesta incluye un campo "next" con la URL de la siguiente página
    // (o null si estamos en la última página).
    NumeroPagina: Integer;      // Página actual que estamos cargando
    MaxPaginas: Integer;        // Límite de páginas para no sobrecargar
    HayMasPaginas: Boolean;     // Control del bucle de paginación

    // ─── Variables temporales para construir cada registro ────────────────
    I: Integer;
  begin
    // ─── 1. Preparamos la tabla destino ───────────────────────────────────
    // Borramos los datos existentes para hacer una importación limpia.
    // En un escenario real habría que hacer una importación incremental,
    // pero para este ejercicio la aproximación más sencilla es borrar y recargar.
    Characters.DeleteAll();

    // ─── 2. Bucle de paginación ───────────────────────────────────────────
    // Cargamos un máximo de 3 páginas (= 60 personajes) para no sobrecargar
    // la API ni BC. En un sistema productivo se podría cargar todo.
    NumeroPagina := 1;
    MaxPaginas := 3;
    HayMasPaginas := true;

    while HayMasPaginas and (NumeroPagina <= MaxPaginas) do begin
      // ── Construimos la URL con el número de página ──────────────────────
      // Ejemplo: https://thesimpsonsapi.com/api/characters?page=1
      //          https://thesimpsonsapi.com/api/characters?page=2
      ApiUrl := GetBaseUrl() + '/characters?page=' + Format(NumeroPagina);

      // ── Llamamos a la API y obtenemos la respuesta ──────────────────────
      // Esta llamada puede lanzar un Error() si hay problemas de red.
      ResponseText := CallAPI(ApiUrl);

      // ── Parseamos el JSON de la respuesta ─────────────────────────────
      // La respuesta tiene esta estructura:
      // {
      //   "count": 1182,                    ← total de personajes
      //   "next": "...?page=2",             ← URL siguiente página (o null)
      //   "prev": null,                     ← URL página anterior (o null)
      //   "pages": 60,                      ← número total de páginas
      //   "results": [ {...}, {...}, ... ]  ← array con los personajes
      // }
      //
      // PASO 1: ReadFrom() convierte el texto JSON en un objeto manipulable.
      // A partir de este momento podemos acceder a sus campos con .Get()
      JsonObj.ReadFrom(ResponseText);

      // ── Verificamos si hay siguiente página ─────────────────────────────
      // La API indica si hay más datos con el campo "next".
      // Cuando es la última página, "next" vale null.
      if JsonObj.Get('next', NextToken) then
        HayMasPaginas := not NextToken.AsValue().IsNull()
      else
        HayMasPaginas := false;

      // ── Obtenemos el array de personajes ───────────────────────────────
      // PASO 2: .Get('results', JsonToken) busca la clave "results" y guarda
      //         el resultado en JsonToken (que en este caso es un array).
      // PASO 3: .AsArray() convierte el JsonToken en un JsonArray iterable.
      JsonObj.Get('results', JsonToken);
      JsonArr := JsonToken.AsArray();

      // ── Iteramos cada personaje del array ──────────────────────────────
      // Los índices del array son base-0: el primer elemento es el índice 0.
      // .Count() nos da el número total de elementos.
      for I := 0 to JsonArr.Count() - 1 do begin
        // PASO 4: .Get(I, JsonToken) obtiene el elemento en la posición I.
        JsonArr.Get(I, JsonToken);

        // PASO 5: .AsObject() convierte el JsonToken en un JsonObject
        //         para poder acceder a sus campos individuales.
        CharJson := JsonToken.AsObject();

        // ── Creamos el registro en la tabla ─────────────────────────────
        Characters.Init();

        // Leemos el campo "id" (número entero)
        CharJson.Get('id', JsonToken);
        Characters."ID Personaje" := JsonToken.AsValue().AsInteger();

        // Leemos el campo "name" (texto)
        CharJson.Get('name', JsonToken);
        // CopyStr() limita el texto a la longitud máxima del campo (100)
        // para evitar errores de desbordamiento si el nombre fuera muy largo.
        Characters."Nombre Personaje" :=
          CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(Characters."Nombre Personaje"));

        // Guardamos la fecha y hora local de la importación
        Characters."Fecha Actualización" := CurrentDateTime();

        // Insert() guarda el registro. Si ya existe con ese ID, lo actualizamos.
        if not Characters.Insert() then
          Characters.Modify();
      end;

      NumeroPagina += 1;
    end;
  end;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROCEDIMIENTO PÚBLICO 2: GetCharacterByName
  // ═══════════════════════════════════════════════════════════════════════════
  /// <summary>
  /// Busca un personaje por nombre en la API y devuelve sus datos detallados
  /// rellenando las variables VAR que recibe como parámetros.
  ///
  /// Las páginas de tipo "temporal" (sin tabla de origen) usan variables globales
  /// para mostrar datos. Este procedimiento rellena esas variables.
  /// </summary>
  /// <param name="CharacterName">Nombre del personaje a buscar (ej: "Homer").</param>
  /// <param name="Nombre">Nombre completo del personaje encontrado.</param>
  /// <param name="Edad">Edad del personaje (0 si no está disponible).</param>
  /// <param name="FechaNacimiento">Fecha de nacimiento en formato texto (puede estar vacío).</param>
  /// <param name="Genero">Género del personaje (Male/Female).</param>
  /// <param name="Ocupacion">Ocupación del personaje.</param>
  /// <param name="Estado">Estado: "Alive" (vivo) o "Deceased" (fallecido).</param>
  /// <param name="PortraitUrl">URL completa de la imagen del personaje.</param>
  /// <param name="Frases">Frases célebres, separadas por ' • '.</param>
  procedure GetCharacterByName(
    CharacterName: Text;
    var CharId: Integer;
    var Nombre: Text;
    var Edad: Integer;
    var FechaNacimiento: Text;
    var Genero: Text;
    var Ocupacion: Text;
    var Estado: Text;
    var PortraitUrl: Text;
    var Frases: Text
  )
  var
    ResponseText: Text;
    ApiUrl: Text;
    JsonObj: JsonObject;
    JsonArr: JsonArray;
    JsonToken: JsonToken;
    CharJson: JsonObject;
    PhrasesBuilder: TextBuilder;
    I: Integer;
    // ─── Variables para la búsqueda paginada ──────────────────────────────
    // ¡IMPORTANTE! El parámetro ?name= de esta API NO filtra resultados.
    // Siempre devuelve los personajes ordenados por ID, empezando por Homer.
    // Por eso tenemos que paginar manualmente y comparar el nombre nosotros.
    NombreBusquedaLC: Text;   // Nombre de búsqueda en minúsculas para comparar
    NombrePersonajeLC: Text;  // Nombre del personaje en minúsculas
    PaginaActual: Integer;    // Página que se está consultando ahora
    Encontrado: Boolean;      // Flag: ya encontramos el personaje
    MaxPaginasBusqueda: Integer; // Límite de páginas para no hacer llamadas infinitas
  begin
    // ─── 1. Preparamos la búsqueda ─────────────────────────────────────────
    // Convertimos a minúsculas para hacer la comparación insensible a mayúsculas.
    // LowerCase() es la función de AL para convertir texto a minúsculas.
    NombreBusquedaLC := LowerCase(CharacterName);
    PaginaActual := 1;
    Encontrado := false;
    // Buscamos en las primeras 15 páginas (300 personajes).
    // Los personajes conocidos son en su mayoría los de menor ID.
    MaxPaginasBusqueda := 15;

    // ─── 2. Bucle de búsqueda paginada ─────────────────────────────────────
    // Recorremos página a página hasta encontrar el personaje o agotar el límite.
    // Este es el patrón estándar cuando una API no soporta búsqueda por nombre:
    //   > GET page 1 → recorrer resultados → si no está → GET page 2 → etc.
    while (not Encontrado) and (PaginaActual <= MaxPaginasBusqueda) do begin
      // Construimos la URL de la página actual.
      // El parámetro ?page= indica qué página de 20 resultados queremos.
      ApiUrl := GetBaseUrl() + '/characters?page=' + Format(PaginaActual);
      ResponseText := CallAPI(ApiUrl);

      // Parseamos el JSON de esta página
      JsonObj.ReadFrom(ResponseText);
      JsonObj.Get('results', JsonToken);
      JsonArr := JsonToken.AsArray();

      // ── Buscamos en los 20 personajes de esta página ────────────────────
      for I := 0 to JsonArr.Count() - 1 do
        if not Encontrado then begin
          JsonArr.Get(I, JsonToken);
          CharJson := JsonToken.AsObject();

          // Leemos el nombre del personaje y lo comparamos en minúsculas.
          // StrPos() es la función de AL equivalente a CONTAINS en otros lenguajes.
          // Devuelve la posición donde empieza el substring, o 0 si no está.
          // Así "homer" coincide con "Homer Simpson", "Homer vs. Patty and Selma", etc.
          CharJson.Get('name', JsonToken);
          NombrePersonajeLC := LowerCase(JsonToken.AsValue().AsText());

          if StrPos(NombrePersonajeLC, NombreBusquedaLC) > 0 then
            Encontrado := true;
        end;

      if not Encontrado then
        PaginaActual += 1;
    end;

    // ─── 3. Si no encontramos el personaje, mostramos un error claro ───────
    if not Encontrado then
      Error('No se encontró ningún habitante de Springfield con el nombre "%1".\' +
            'Prueba con: Homer, Bart, Lisa, Marge, Burns, Flanders, Apu, Moe...', CharacterName);

    // ─── 4. Extraemos cada campo del objeto JSON del personaje encontrado ────
    // ── Campo: id (clave numérica del personaje en la API) ──────────────────
    CharJson.Get('id', JsonToken);
    CharId := JsonToken.AsValue().AsInteger();
    // ── Campo: name (siempre presente, tipo texto) ──────────────────────────
    CharJson.Get('name', JsonToken);
    Nombre := JsonToken.AsValue().AsText();

    // ── Campo: age (puede ser null = personaje sin edad definida) ───────────
    // MANEJO DE NULOS: Antes de leer un valor que puede ser null,
    // debemos verificar con .IsNull(). Si intentamos .AsInteger() en un
    // valor null, BC lanzaría un error en tiempo de ejecución.
    Edad := 0;  // Valor por defecto si no hay edad
    if CharJson.Get('age', JsonToken) then
      if not JsonToken.AsValue().IsNull() then
        Edad := JsonToken.AsValue().AsInteger();

    // ── Campo: birthdate (puede ser null, formato "YYYY-MM-DD") ────────────
    FechaNacimiento := '';
    if CharJson.Get('birthdate', JsonToken) then
      if not JsonToken.AsValue().IsNull() then
        FechaNacimiento := JsonToken.AsValue().AsText();

    // ── Campo: gender (siempre presente) ────────────────────────────────────
    CharJson.Get('gender', JsonToken);
    Genero := JsonToken.AsValue().AsText();

    // ── Campo: occupation (siempre presente) ────────────────────────────────
    CharJson.Get('occupation', JsonToken);
    Ocupacion := JsonToken.AsValue().AsText();

    // ── Campo: status ("Alive" o "Deceased") ────────────────────────────────
    CharJson.Get('status', JsonToken);
    Estado := JsonToken.AsValue().AsText();

    // ── Campo: portrait_path (ruta relativa, ej: "/character/1.webp") ───────
    // La API devuelve solo la ruta relativa. La combinamos con la URL base del CDN
    // para construir la URL completa:
    //   Base CDN (500px):  "https://cdn.thesimpsonsapi.com/500"
    //   Ruta relativa:     "/character/1.webp"
    //   Resultado:         "https://cdn.thesimpsonsapi.com/500/character/1.webp"
    CharJson.Get('portrait_path', JsonToken);
    PortraitUrl := GetCharacterImageBaseUrl() + JsonToken.AsValue().AsText();

    // ── Campo: phrases (ARRAY de textos con las frases del personaje) ────────
    // Este es un ejemplo de array de valores simples en JSON:
    // "phrases": ["Doh!", "Woo-hoo!", "Why you little...!"]
    //
    // Lo convertimos en un único texto con las frases separadas por ' • '
    // para poder mostrarlo en un campo de texto de la página.
    CharJson.Get('phrases', JsonToken);
    JsonArr := JsonToken.AsArray();

    Clear(PhrasesBuilder);
    for I := 0 to JsonArr.Count() - 1 do begin
      JsonArr.Get(I, JsonToken);

      // Añadimos separador entre frases (no antes de la primera)
      if I > 0 then
        PhrasesBuilder.Append(' • ');

      PhrasesBuilder.Append(JsonToken.AsValue().AsText());
    end;

    Frases := PhrasesBuilder.ToText();

    // Si el personaje no tiene frases registradas, mostramos un mensaje apropiado
    if Frases = '' then
      Frases := '(Este personaje no tiene frases registradas en la API)';
  end;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROCEDIMIENTO PÚBLICO 3: GetRandomLocation
  // ═══════════════════════════════════════════════════════════════════════════
  /// <summary>
  /// Obtiene una localización aleatoria de Springfield desde la API.
  /// La API tiene 477 localizaciones (IDs del 1 al 477).
  /// Generamos un número aleatorio y consultamos directamente ese ID.
  /// </summary>
  /// <param name="Nombre">Nombre de la localización (ej: "Moe's Tavern").</param>
  /// <param name="Ciudad">Ciudad (normalmente "Springfield").</param>
  /// <param name="Uso">Uso del lugar (ej: "Bar", "Residential", "Education").</param>
  /// <param name="ImageUrl">URL completa de la imagen del lugar.</param>
  procedure GetRandomLocation(
    var Nombre: Text;
    var Ciudad: Text;
    var Uso: Text;
    var ImageUrl: Text
  )
  var
    ResponseText: Text;
    ApiUrl: Text;
    JsonObj: JsonObject;
    JsonToken: JsonToken;
    RandomId: Integer;
  begin
    // ─── 1. Generamos un ID aleatorio entre 1 y 477 ─────────────────────────
    // La API tiene 477 localizaciones. La función Random() de AL devuelve un
    // número entero aleatorio entre 1 y el número que le pasamos (inclusive).
    RandomId := Random(477);

    // Salvaguarda: Random puede devolver 0 en casos extremos
    if RandomId = 0 then
      RandomId := 1;

    // ─── 2. Llamamos al endpoint de localización por ID ─────────────────────
    // La API soporta consulta directa por ID:
    // https://thesimpsonsapi.com/api/locations/{id}
    // Ejemplo: https://thesimpsonsapi.com/api/locations/5  → Moe's Tavern
    ApiUrl := GetBaseUrl() + '/locations/' + Format(RandomId);
    ResponseText := CallAPI(ApiUrl);

    // ─── 3. Parseamos la respuesta ─────────────────────────────────────────
    // La respuesta de un elemento individual (no paginada) tiene esta estructura:
    // {
    //   "id": 5,
    //   "name": "Moe's Tavern",
    //   "image_path": "/location/5.webp",
    //   "town": "Springfield",
    //   "use": "Bar",
    //   "description": "...",
    //   "first_appearance_ep": { ... }
    // }
    JsonObj.ReadFrom(ResponseText);

    // ── Campo: name ─────────────────────────────────────────────────────────
    JsonObj.Get('name', JsonToken);
    Nombre := JsonToken.AsValue().AsText();

    // ── Campo: town (puede estar vacío: "") ──────────────────────────────────
    Ciudad := '';
    if JsonObj.Get('town', JsonToken) then
      if not JsonToken.AsValue().IsNull() then
        Ciudad := JsonToken.AsValue().AsText();
    if Ciudad = '' then
      Ciudad := 'Springfield';

    // ── Campo: use (descripción del uso del lugar) ───────────────────────────
    // NOTA: "use" es una palabra reservada en AL/SQL, pero aquí es solo una
    // clave JSON que leemos como texto, por lo que no hay conflicto.
    Uso := '';
    if JsonObj.Get('use', JsonToken) then
      if not JsonToken.AsValue().IsNull() then
        Uso := JsonToken.AsValue().AsText();

    // ── Campo: image_path (ruta relativa de la imagen) ──────────────────────
    // Para localizaciones usamos el tamaño 1280px del CDN (más detalle):
    //   Base CDN (1280px): "https://cdn.thesimpsonsapi.com/1280"
    //   Ruta relativa:     "/location/5.webp"
    //   Resultado:         "https://cdn.thesimpsonsapi.com/1280/location/5.webp"
    ImageUrl := '';
    if JsonObj.Get('image_path', JsonToken) then
      if not JsonToken.AsValue().IsNull() then
        ImageUrl := GetLocationImageBaseUrl() + JsonToken.AsValue().AsText();
  end;

  // ===========================================================================
  // SECCIÓN B: PROCEDIMIENTOS LOCALES (PRIVADOS)
  // ===========================================================================
  // Los procedimientos marcados como "local" solo son accesibles dentro de
  // este codeunit. Son el equivalente de métodos privados en otros lenguajes.

  // ═══════════════════════════════════════════════════════════════════════════
  // PROCEDIMIENTO LOCAL: CallAPI
  // ═══════════════════════════════════════════════════════════════════════════
  /// <summary>
  /// Realiza una petición HTTP GET a la URL indicada y devuelve el cuerpo
  /// de la respuesta como texto.
  ///
  /// ─── CÓMO FUNCIONA HTTP EN AL ───────────────────────────────────────────
  /// BC usa tres tipos principales para llamadas HTTP:
  ///   HttpClient         → El "cliente" que hace las peticiones.
  ///                        Solo necesitamos uno por codeunit.
  ///   HttpResponseMessage→ El "sobre" que contiene la respuesta del servidor:
  ///                        código de estado, cabeceras, y cuerpo.
  ///   HttpContent        → El cuerpo de la petición o respuesta (para leer/escribir).
  ///
  /// Para llamadas GET simples (sin cuerpo ni autenticación), el flujo es:
  ///   1. HttpClient.Get(url, response) → hace la llamada
  ///   2. response.IsSuccessStatusCode() → comprueba si fue bien (HTTP 200-299)
  ///   3. response.Content().ReadAs(text) → lee el cuerpo de la respuesta
  /// ────────────────────────────────────────────────────────────────────────
  /// </summary>
  /// <param name="Url">URL completa a la que hacer la petición GET.</param>
  /// <returns>Cuerpo de la respuesta en formato texto (generalmente JSON).</returns>
  local procedure CallAPI(Url: Text): Text
  var
    HttpClient: HttpClient;         // El agente que ejecuta la llamada HTTP
    HttpResponse: HttpResponseMessage; // La respuesta completa del servidor
    ResponseText: Text;             // El cuerpo de la respuesta como texto
  begin
    // ─── PASO 1: Ejecutamos la petición GET ────────────────────────────────
    // HttpClient.Get() envía la petición HTTP y espera la respuesta.
    // Es una llamada SÍNCRONA: BC esperará hasta recibir respuesta (o timeout).
    //
    // Devuelve TRUE si la comunicación fue posible, FALSE si hubo error de red
    // (sin conexión, timeout, DNS no resuelto, etc.).
    // OJO: un FALSE aquí NO significa "error HTTP" sino "no se pudo conectar".
    if not HttpClient.Get(Url, HttpResponse) then
      Error('No se pudo conectar con la API de los Simpsons.' + '\' +
            'Comprueba la conexión a Internet o el estado de la API.' + '\' +
            'URL: %1', Url);

    // ─── PASO 2: Verificamos el código de estado HTTP ─────────────────────
    // IsSuccessStatusCode() devuelve TRUE si el código HTTP es 2xx (éxito).
    // Códigos comunes:
    //   200 OK           → Todo correcto, hay datos
    //   404 Not Found    → El recurso no existe (ej: personaje con ese ID no existe)
    //   429 Too Many Req → Demasiadas peticiones (la API nos limita)
    //   500 Server Error → Error interno del servidor de la API
    if not HttpResponse.IsSuccessStatusCode() then
      Error('La API respondió con un error HTTP %1.' + '\' +
            'URL: %2', HttpResponse.HttpStatusCode(), Url);

    // ─── PASO 3: Leemos el cuerpo de la respuesta ─────────────────────────
    // .Content() accede al cuerpo de la respuesta (un objeto HttpContent).
    // .ReadAs(Text) lee ese contenido y lo vuelca en la variable de texto.
    // En este punto, ResponseText contiene el JSON completo de la API.
    HttpResponse.Content().ReadAs(ResponseText);

    exit(ResponseText);
  end;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROCEDIMIENTO LOCAL: GetBaseUrl
  // ═══════════════════════════════════════════════════════════════════════════
  /// <summary>
  /// Devuelve la URL base de la API de los Simpsons.
  /// Centralizamos la URL para facilitar cambios futuros (ej: versión de API).
  /// </summary>
  local procedure GetBaseUrl(): Text
  begin
    exit('https://thesimpsonsapi.com/api');
  end;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROCEDIMIENTO LOCAL: GetCharacterImageBaseUrl
  // ═══════════════════════════════════════════════════════════════════════════
  /// <summary>
  /// Devuelve la URL base del CDN para imágenes de PERSONAJES (tamaño 500px).
  /// La API devuelve rutas relativas como "/character/1.webp".
  /// El CDN sirve las imágenes en tres tamaños: 200px, 500px y 1280px.
  /// Para retratos de personajes, 500px ofrece el equilibrio ideal entre
  /// calidad visual y velocidad de carga.
  /// Resultado: "https://cdn.thesimpsonsapi.com/500" + "/character/1.webp"
  ///          = "https://cdn.thesimpsonsapi.com/500/character/1.webp"
  /// </summary>
  local procedure GetCharacterImageBaseUrl(): Text
  begin
    exit('https://cdn.thesimpsonsapi.com/500');
  end;

  // ═══════════════════════════════════════════════════════════════════════════
  // PROCEDIMIENTO LOCAL: GetLocationImageBaseUrl
  // ═══════════════════════════════════════════════════════════════════════════
  /// <summary>
  /// Devuelve la URL base del CDN para imágenes de LOCALIZACIONES (tamaño 1280px).
  /// Las localizaciones se muestran a mayor tamaño, por lo que usamos
  /// la resolución más alta disponible en el CDN.
  /// Resultado: "https://cdn.thesimpsonsapi.com/1280" + "/location/5.webp"
  ///          = "https://cdn.thesimpsonsapi.com/1280/location/5.webp"
  /// </summary>
  local procedure GetLocationImageBaseUrl(): Text
  begin
    exit('https://cdn.thesimpsonsapi.com/1280');
  end;

}

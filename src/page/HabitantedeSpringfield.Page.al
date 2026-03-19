// =============================================================================
// PÁGINA: Habitante de Springfield
// OBJETO: Page 50002
// =============================================================================
// Propósito:
//   Permite consultar los datos detallados de cualquier personaje de Springfield
//   introduciendo su nombre y pulsando "Buscar".
//   Muestra: nombre, edad, fecha de nacimiento, género, ocupación, estado,
//            frases célebres y retrato (mediante ControlAddin).
//
// ─────────────────────────────────────────────────────────────────────────────
// CONCEPTO CLAVE: PÁGINA TEMPORAL (sin tabla de origen)
// ─────────────────────────────────────────────────────────────────────────────
// Una "página temporal" en BC es una página que NO tiene una tabla vinculada
// como SourceTable. En lugar de leer y escribir datos en la base de datos,
// trabaja exclusivamente con variables declaradas en la propia página.
//
// ¿Cuándo usar este patrón?
//   - Cuando los datos vienen de una fuente externa (una API, en este caso).
//   - Cuando los datos son de solo consulta y no necesitan persistencia.
//   - Para formularios de entrada de datos que procesan información sin guardar.
//
// ¿Cómo funciona?
//   - Los campos de la página no apuntan a campos de tabla (Rec.Campo),
//     sino a variables locales de la página (NombrePersonaje, Edad, etc.).
//   - BC renderiza los campos igual que en una página normal.
//   - Los datos existen SOLO mientras la página está abierta.
//     Al cerrarla, todo se pierde (si no se guarda explícitamente).
// =============================================================================

page 50002 "Habitante de Springfield"
{
    Caption = 'Habitante de Springfield';
    // PageType = Card muestra todos los campos en una sola tarjeta (no lista).
    PageType = Card;
    // Al NO declarar SourceTable, la página no lee datos de ninguna tabla.
    // Todos los datos provienen de las variables declaradas más abajo en "var".
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(Content)
        {
            // ── Grupo de búsqueda ──────────────────────────────────────────────────
            // Este grupo contiene el campo de texto para introducir el nombre
            // del personaje a buscar. Es el "input" de la página.
            group(GrupoBusqueda)
            {
                Caption = '🔍 Buscar Habitante de Springfield';

                field(NombreBusqueda; NombreBusqueda)
                {
                    ApplicationArea = All;
                    Caption = 'Nombre del Personaje';
                    ToolTip = 'Introduce el nombre del personaje a buscar (ej: Homer, Burns, Flanders...)';
                    // ShowMandatory indica visualmente que este campo debe rellenarse.
                    ShowMandatory = true;

                    // El trigger OnValidate se ejecuta cuando el usuario sale del campo.
                    // Si pulsa Enter en este campo, llamamos automáticamente a la búsqueda.
                    trigger OnValidate()
                    begin
                        BuscarPersonaje();
                    end;
                }
            }

            // ── Grupo de información del personaje ───────────────────────────────
            // Todos los campos de este grupo son Editable = false:
            // solo muestran datos, no permiten edición.
            group(GrupoInformacion)
            {
                Caption = '👤 Datos del Personaje';
                Editable = false;
                // Visible controla si el grupo se muestra.
                // Lo ocultamos hasta que se haya cargado un personaje.
                Visible = PersonajeCargado;

                field(NombrePersonaje; NombrePersonaje)
                {
                    ApplicationArea = All;
                    Caption = 'Nombre Completo';
                    Style = Strong;
                    ToolTip = 'Nombre completo del personaje de Springfield.';
                }

                field(Genero; Genero)
                {
                    ApplicationArea = All;
                    Caption = 'Género';
                    ToolTip = 'Género del personaje: Male o Female.';
                }

                field(Edad; Edad)
                {
                    ApplicationArea = All;
                    Caption = 'Edad';
                    ToolTip = 'Edad del personaje (0 si no está registrada en la API).';
                }

                field(FechaNacimiento; FechaNacimiento)
                {
                    ApplicationArea = All;
                    Caption = 'Fecha de Nacimiento';
                    ToolTip = 'Fecha de nacimiento del personaje en formato AAAA-MM-DD (puede estar vacío).';
                }

                field(Ocupacion; Ocupacion)
                {
                    ApplicationArea = All;
                    Caption = 'Ocupación';
                    MultiLine = true;
                    ToolTip = 'Descripción de la ocupación o trabajo del personaje.';
                }

                // ── Campo Estado con color condicional ─────────────────────────────
                // StyleExpr permite cambiar el estilo del campo dinámicamente
                // usando una expresión AL (en este caso, una variable).
                field(Estado; Estado)
                {
                    ApplicationArea = All;
                    Caption = 'Estado';
                    StyleExpr = EstiloEstado;
                    ToolTip = 'Estado vital del personaje: Alive (vivo) o Deceased (fallecido).';
                }

                // ── URL de la fotografía del personaje ──────────────────────────
                // La CSP de BC SaaS bloquea imágenes externas dentro del iframe de
                // un ControlAddin. La solución fiable es mostrar la URL como enlace.
                // ExtendedDatatype = URL convierte el campo en un hipervínculo:
                // BC muestra un icono de enlace que abre la URL en el navegador.
                field(PortraitUrl; PortraitUrl)
                {
                    ApplicationArea = All;
                    Caption = 'Fotografía (URL)';
                    Editable = false;
                    ExtendedDatatype = URL;
                    ToolTip = 'URL de la fotografía del personaje. Haz clic en el icono para abrirla en el navegador.';
                }
            }

            // ── Grupo de frases célebres ──────────────────────────────────────────
            group(GrupoFrases)
            {
                Caption = '💬 Frases Célebres';
                Editable = false;
                Visible = PersonajeCargado;

                field(Frases; Frases)
                {
                    ApplicationArea = All;
                    Caption = 'Frases';
                    MultiLine = true;
                    ToolTip = 'Frases célebres del personaje. Separadas por el símbolo •';
                }
            }

            // ── Grupo del ControlAddin (Retrato + Botón de voz) ──────────────────
            group(GrupoRetrato)
            {
                Caption = '🖼️ Retrato';
                Visible = PersonajeCargado;

                // usercontrol declara un ControlAddin embebido en la página.
                // El primer parámetro es el nombre del control en esta página (alias).
                // El segundo parámetro es el nombre del objeto ControlAddin registrado.
                usercontrol(RetratosAddin; "Simpsons Portrait")
                {
                    ApplicationArea = All;

                    // ── Evento: ControlAddinReady ──────────────────────────────────
                    // Este evento se dispara cuando el JavaScript del ControlAddin
                    // ha cargado completamente y está listo para recibir comandos.
                    // Es el equivalente a "DOMContentLoaded" en JavaScript.
                    trigger ControlAddinReady()
                    begin
                        // El addin JavaScript ha terminado de cargar y está listo.
                        // Marcamos el flag y si ya teníamos datos cargados, los enviamos.
                        // Este es el patrón correcto para sincronizar AL con el addin:
                        //   - BC puede cargar datos ANTES de que el addin esté listo.
                        //   - El addin puede estar listo ANTES de que haya datos.
                        // El flag AddinReady y PersonajeCargado resuelven ambos casos.
                        AddinReady := true;
                        if PersonajeCargado then
                            EnviarDatosAlAddin();
                    end;

                    // ── Evento: PhraseButtonClicked ────────────────────────────────
                    // El ControlAddin notifica a AL cuando el usuario pulsa el botón
                    // de reproducción en el addin JavaScript.
                    trigger PhraseButtonClicked(SelectedPhrase: Text)
                    begin
                        // No hacemos nada adicional aquí; el addin ya reproduce la frase
                        // de forma autónoma en JavaScript. Este evento existe para poder
                        // registrar logs o realizar acciones adicionales en BC si se quisiera.
                        Message('🔊 Reproduciendo: "%1"', SelectedPhrase);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // ── Acción: Buscar ────────────────────────────────────────────────────
            action(AccionBuscar)
            {
                Caption = '🔍 Buscar Personaje';
                ApplicationArea = All;
                Image = Find;
                ToolTip = 'Busca el personaje introducido en la API de los Simpsons.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    BuscarPersonaje();
                end;
            }

            // ── Acción: Guardar en Characters ────────────────────────────────────
            action(GuardarPersonaje)
            {
                Caption = '💾 Guardar en Characters';
                ApplicationArea = All;
                Image = Save;
                ToolTip = 'Guarda este personaje en la tabla Characters de Business Central.';
                Enabled = PersonajeCargado;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    Characters: Record Characters;
                begin
                    // Guardamos el personaje actual en la tabla persistente Characters.
                    // Si ya existe (mismo ID), actualizamos su registro.
                    if Characters.Get(CharacterId) then begin
                        Characters."Nombre Personaje" := CopyStr(NombrePersonaje, 1, MaxStrLen(Characters."Nombre Personaje"));
                        Characters."Fecha Actualización" := CurrentDateTime();
                        Characters.Modify();
                    end else begin
                        Characters.Init();
                        Characters."ID Personaje" := CharacterId;
                        Characters."Nombre Personaje" := CopyStr(NombrePersonaje, 1, MaxStrLen(Characters."Nombre Personaje"));
                        Characters."Fecha Actualización" := CurrentDateTime();
                        Characters.Insert();
                    end;
                    Message('✅ Personaje "%1" guardado en Business Central.', NombrePersonaje);
                end;
            }
        }
    }

    // ===========================================================================
    // VARIABLES DE LA PÁGINA (sustituto de la tabla en una "página temporal")
    // ===========================================================================
    // En una página CON SourceTable, los datos vienen de "Rec" (el registro actual).
    // En esta página SIN SourceTable, los datos son estas variables locales.
    // BC permite usar variables como fuente de los campos de la página igual que
    // si fueran campos de tabla. La diferencia es que solo existen en memoria.
    var
        // ── Datos de búsqueda ──────────────────────────────────────────────────
        NombreBusqueda: Text[100];    // Texto que introduce el usuario para buscar

        // ── Datos del personaje (rellenados por el codeunit) ───────────────────
        CharacterId: Integer;         // ID interno del personaje en la API
        NombrePersonaje: Text[100];   // Nombre completo
        Edad: Integer;                // Edad (0 si desconocida)
        FechaNacimiento: Text[50];    // Fecha de nacimiento (vacío si null en API)
        Genero: Text[50];             // "Male" / "Female"
        Ocupacion: Text[250];         // Descripción de la ocupación
        Estado: Text[50];             // "Alive" / "Deceased"
        PortraitUrl: Text[250];       // URL completa de la imagen del personaje
        Frases: Text[2048];           // Frases célebres separadas por " • "

        // ── Variables de control de UI ─────────────────────────────────────────
        PersonajeCargado: Boolean;    // Controla la visibilidad de los grupos de datos
        EstiloEstado: Text;           // Estilo dinámico del campo Estado (verde/rojo)
        AddinReady: Boolean;          // True cuando el JavaScript del addin está cargado
                                      // ===========================================================================
                                      // PROCEDIMIENTOS LOCALES DE LA PÁGINA
                                      // ===========================================================================

    /// <summary>
    /// Procedimiento principal de búsqueda. Valida el nombre, llama al API
    /// y actualiza todas las variables de la página con los datos recibidos.
    /// </summary>
    local procedure BuscarPersonaje()
    var
        SimpsonsAPI: Codeunit "Simpsons API";
        EdadTemp: Integer;
        NombreTemp: Text;
        FechaNacimientoTemp: Text;
        GeneroTemp: Text;
        OcupacionTemp: Text;
        EstadoTemp: Text;
        PortraitUrlTemp: Text;
        FrasesTemp: Text;
    begin
        // ── Validación básica ─────────────────────────────────────────────────
        if NombreBusqueda = '' then
            Error('¡Por favor, introduce el nombre de un habitante de Springfield!');

        // ── Llamada al codeunit de API ─────────────────────────────────────────
        // Pasamos variables VAR para que el codeunit las rellene con los datos.
        // Si la API falla o no encuentra el personaje, el codeunit lanzará un Error()
        // que BC mostrará automáticamente al usuario.
        SimpsonsAPI.GetCharacterByName(
          NombreBusqueda,
          CharacterId,
          NombreTemp,
          EdadTemp,
          FechaNacimientoTemp,
          GeneroTemp,
          OcupacionTemp,
          EstadoTemp,
          PortraitUrlTemp,
          FrasesTemp
        );

        // ── Volcamos los datos en las variables de la página ───────────────────
        NombrePersonaje := CopyStr(NombreTemp, 1, MaxStrLen(NombrePersonaje));
        Edad := EdadTemp;
        FechaNacimiento := CopyStr(FechaNacimientoTemp, 1, MaxStrLen(FechaNacimiento));
        Genero := CopyStr(GeneroTemp, 1, MaxStrLen(Genero));
        Ocupacion := CopyStr(OcupacionTemp, 1, MaxStrLen(Ocupacion));
        Estado := CopyStr(EstadoTemp, 1, MaxStrLen(Estado));
        PortraitUrl := CopyStr(PortraitUrlTemp, 1, MaxStrLen(PortraitUrl));
        Frases := CopyStr(FrasesTemp, 1, MaxStrLen(Frases));

        // ── Actualizamos los controles de UI ──────────────────────────────────
        // Calculamos el estilo del campo "Estado" según si el personaje está vivo
        // o ha fallecido. BC aplica colores predefinidos según el estilo:
        //   Favorable = verde  (personaje vivo)
        //   Unfavorable = rojo (personaje fallecido)
        if Estado = 'Alive' then
            EstiloEstado := 'Favorable'
        else
            EstiloEstado := 'Unfavorable';

        PersonajeCargado := true;

        // ── Forzamos la actualización visual de la página ─────────────────────
        // CurrPage.Update(false) refresca todos los campos de la página.
        // El parámetro FALSE indica que no guardamos cambios en tabla (no hay tabla).
        CurrPage.Update(false);

        // ── Enviamos los datos al ControlAddin ────────────────────────────────
        EnviarDatosAlAddin();
    end;

    /// <summary>
    /// Envía los datos del personaje al ControlAddin (JavaScript) para
    /// mostrar la imagen y preparar la reproducción de frases.
    /// </summary>
    local procedure EnviarDatosAlAddin()
    begin
        // Solo llamamos al addin si está marcado como listo (ControlAddinReady ya disparó)
        // y si tenemos datos de un personaje cargado.
        // Si el addin aún no está listo, ControlAddinReady() llamará a este
        // procedimiento automáticamente cuando termine de cargar.
        if not AddinReady then exit;
        if not PersonajeCargado then exit;

        // CurrPage.RetratosAddin.DisplayPortrait() llama a la función JavaScript
        // "DisplayPortrait" definida en el ControlAddin, pasando la URL de la imagen
        // y el nombre del personaje como parámetros.
        CurrPage.RetratosAddin.DisplayPortrait(PortraitUrl, NombrePersonaje);
        CurrPage.RetratosAddin.SetPhrases(Frases);
    end;

    /// <summary>
    /// Permite establecer el nombre de búsqueda desde otras páginas (por ejemplo,
    /// desde CharactersList cuando el usuario selecciona un personaje).
    /// </summary>
    procedure EstablecerBusqueda(Nombre: Text)
    begin
        NombreBusqueda := CopyStr(Nombre, 1, MaxStrLen(NombreBusqueda));
        // Buscamos automáticamente si se nos pasa un nombre
        if NombreBusqueda <> '' then
            BuscarPersonaje();
    end;
}

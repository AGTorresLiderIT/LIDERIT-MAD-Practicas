// =============================================================================
// CONTROL ADDIN: Simpsons Portrait
// =============================================================================
// Propósito:
//   Un ControlAddin es un componente personalizado que combina AL (Business Central)
//   con JavaScript/HTML para mostrar contenido web interactivo dentro de una
//   página de BC.
//
// ─────────────────────────────────────────────────────────────────────────────
// CONCEPTO CLAVE: ¿QUÉ ES UN CONTROL ADD-IN?
// ─────────────────────────────────────────────────────────────────────────────
// BC usa HTML/JavaScript para renderizar su interfaz web. Un ControlAddin
// te permite insertar tu propio HTML+JS en una "caja" dentro de una página de BC.
//
// La comunicación entre AL y JavaScript funciona en ambas direcciones:
//
//   AL → JavaScript:
//     En AL llamas a: CurrPage.MiAddin.MiFuncion(parametros)
//     Esto ejecuta la función "MiFuncion" definida en el fichero .js
//
//   JavaScript → AL:
//     En JS llamas a: Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('MiEvento', [params])
//     Esto dispara el trigger "MiEvento" definido en el bloque "trigger" del addin en la página
//
// ─────────────────────────────────────────────────────────────────────────────
// ESTRUCTURA DEL CONTROL ADDIN:
//   1. Scripts         → Ficheros .js con las funciones que AL puede llamar
//   2. StartupScript   → Se ejecuta AUTOMÁTICAMENTE al cargar el addin (una vez)
//   3. StyleSheets     → Ficheros .css para dar estilo al addin
//   4. procedure       → Funciones que AL puede llamar en JavaScript
//   5. event           → Eventos que JavaScript puede disparar de vuelta a AL
// =============================================================================

controladdin "Simpsons Portrait"
{
    // ── Dimensiones del área del ControlAddin en la página ───────────────────
    RequestedHeight = 380;    // Alto solicitado en píxeles
    RequestedWidth = 320;     // Ancho solicitado en píxeles
    MinimumHeight = 200;      // Alto mínimo (no puede reducirse más)
    MinimumWidth = 200;       // Ancho mínimo
    VerticalStretch = true;   // Puede expandirse verticalmente
    HorizontalStretch = true; // Puede expandirse horizontalmente

    // ── Ficheros JavaScript ───────────────────────────────────────────────────
    // Scripts: ficheros cargados como bibliotecas. Las funciones en estos ficheros
    //          son las que AL puede invocar con CurrPage.Addin.FunctionName()
    Scripts = 'src/controladdin/js/SimpsonsPortrait.js';

    // StartupScript: se ejecuta UNA SOLA VEZ cuando el addin se inicializa.
    //               Es aquí donde creamos la estructura HTML del addin.
    StartupScript = 'src/controladdin/js/SimpsonsPortrait.startup.js';

    // ── Ficheros CSS ───────────────────────────────────────────────────────────────
    StyleSheets = 'src/controladdin/css/SimpsonsPortrait.css';

    // ===========================================================================
    // EVENTOS: JavaScript → AL
    // ===========================================================================
    // Los eventos se declaran aquí pero se IMPLEMENTAN en la página que usa el addin
    // (en los triggers usercontrol).
    // JavaScript los dispara con: Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(...)

    /// <summary>
    /// Se dispara cuando el JavaScript ha cargado y el addin está listo.
    /// Usar este evento para enviar datos iniciales al addin desde AL.
    /// </summary>
    event ControlAddinReady();

    /// <summary>
    /// Se dispara cuando el usuario pulsa el botón de una frase en el addin.
    /// SelectedPhrase contiene el texto de la frase que se está reproduciendo.
    /// </summary>
    event PhraseButtonClicked(SelectedPhrase: Text);

    // ===========================================================================
    // PROCEDIMIENTOS: AL → JavaScript
    // ===========================================================================
    // Los procedimientos se declaran aquí pero se IMPLEMENTAN en los ficheros .js.
    // AL los llama con: CurrPage.NombreAddinEnPagina.NombreProcedimiento(params)

    /// <summary>
    /// Muestra la imagen del personaje/lugar en el addin.
    /// </summary>
    /// <param name="ImageUrl">URL completa de la imagen (ej: https://...webp).</param>
    /// <param name="Name">Nombre del personaje o lugar para el texto alternativo.</param>
    procedure DisplayPortrait(ImageUrl: Text; Name: Text);

    /// <summary>
    /// Envía las frases célebres del personaje al addin.
    /// El addin creará botones de reproducción para cada frase.
    /// </summary>
    /// <param name="PhrasesText">Texto con las frases separadas por " • ".</param>
    procedure SetPhrases(PhrasesText: Text);
}

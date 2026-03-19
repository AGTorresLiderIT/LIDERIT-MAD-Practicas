// =============================================================================
// PÁGINA: Paseo de Perros
// OBJETO: Page 50003
// =============================================================================
// Propósito:
//   Genera una localización aleatoria de Springfield para que Smithers sepa
//   dónde llevar a los sabuesos del Sr. Burns en su paseo diario.
//   Cada vez que se pulsa "Nuevo Paseo", la API devuelve un lugar diferente.
//
// ─────────────────────────────────────────────────────────────────────────────
// MISMA ARQUITECTURA que "Habitante de Springfield":
//   - Página SIN SourceTable → Usa variables como fuente de datos.
//   - Datos temporales → Solo existen mientras la página está abierta.
//   - Comunicación con API → A través del codeunit "Simpsons API".
// ─────────────────────────────────────────────────────────────────────────────
// CONCEPTO ADICIONAL: OnOpenPage
//   Este trigger se dispara automáticamente cuando BC abre la página.
//   Lo usamos para cargar inmediatamente una localización aleatoria,
//   sin que el usuario tenga que pulsar ningún botón.
// =============================================================================

page 50003 "Paseo de Perros"
{
  Caption = '🐶 Paseo de Perros - Localizaciones de Springfield';
  PageType = Card;
  UsageCategory = Tasks;
  ApplicationArea = All;

  layout
  {
    area(Content)
    {
      // ── Grupo: Instrucción para Smithers ───────────────────────────────
      group(GrupoInstruccion)
      {
        Caption = '📋 Orden del Sr. Burns para Smithers';

        // Campo de solo lectura que muestra las instrucciones.
        // Styl = Attention lo hace destacar visualmente en amarillo/naranja.
        field(Instruccion; Instruccion)
        {
          ApplicationArea = All;
          Caption = 'Orden del Sr. Burns';
          Editable = false;
          MultiLine = true;
          Style = Attention;
          ToolTip = 'Mensaje de instrucciones del Sr. Burns para Smithers.';
        }
      }

      // ── Grupo: Datos de la localización aleatoria ─────────────────────
      group(GrupoLocalizacion)
      {
        Caption = '📍 Destino del Paseo';

        field(NombreLugar; NombreLugar)
        {
          ApplicationArea = All;
          Caption = 'Nombre del Lugar';
          Editable = false;
          Style = Strong;
          ToolTip = 'Nombre del lugar de Springfield al que Smithers debe acudir.';
        }

        field(Ciudad; Ciudad)
        {
          ApplicationArea = All;
          Caption = 'Ciudad';
          Editable = false;
          ToolTip = 'Ciudad donde está ubicado el lugar (normalmente Springfield).';
        }

        field(UsoLugar; UsoLugar)
        {
          ApplicationArea = All;
          Caption = 'Tipo de Lugar';
          Editable = false;
          ToolTip = 'Categoría o uso principal del lugar (Bar, Residencial, Educación, etc.).';
        }

        field(ImagenUrl; ImagenUrl)
        {
          ApplicationArea = All;
          Caption = 'Imagen del Lugar (URL)';
          Editable = false;
          ExtendedDatatype = URL;
          ToolTip = 'URL de la imagen del lugar. Haz clic para verla en el navegador.';
        }
      }

      // ── Grupo: ControlAddin para mostrar la imagen del lugar ───────────
      group(GrupoImagen)
      {
        Caption = '🗺️ Vista del Lugar';
        Visible = LugarCargado;

        usercontrol(ImagenLugarAddin; "Simpsons Portrait")
        {
          ApplicationArea = All;

          trigger ControlAddinReady()
          begin
            // El addin está listo. Marcamos el flag.
            // Si ya habíamos cargado un lugar (desde OnOpenPage), enviamos la imagen ahora.
            AddinReady := true;
            if LugarCargado then
              CurrPage.ImagenLugarAddin.DisplayPortrait(ImagenUrl, NombreLugar);
          end;

          // Este evento no se usa aquí (no hay frases para los lugares),
          // pero debe existir porque el ControlAddin lo declara.
          trigger PhraseButtonClicked(SelectedPhrase: Text)
          begin
            // Sin uso en esta página
          end;
        }
      }
    }
  }

  actions
  {
    area(Processing)
    {
      // ── Acción: Nuevo Paseo (principal) ────────────────────────────────
      action(NuevoPaseo)
      {
        Caption = '🎲 Nuevo Paseo Aleatorio';
        ApplicationArea = All;
        Image = Refresh;
        ToolTip = 'Genera una nueva localización aleatoria de Springfield para el paseo.';
        Promoted = true;
        PromotedCategory = Process;
        PromotedOnly = true;

        trigger OnAction()
        begin
          CargarLocalizacionAleatoria();
        end;
      }
    }
  }

  // ===========================================================================
  // TRIGGER: OnOpenPage
  // ===========================================================================
  // Se ejecuta automáticamente cuando BC abre la página, antes de renderizarla.
  // Ideal para cargar datos iniciales sin que el usuario tenga que hacer nada.
  // En este caso, generamos una primera localización aleatoria al abrir la página.
  trigger OnOpenPage()
  begin
    // Establecemos el texto de instrucción del Sr. Burns
    Instruccion :=
      '"¡Smithers! Lleva inmediatamente a mi jauría a esta localización ' +
      'para mantener la presencia corporativa de Burns Enterprises en Springfield. ' +
      'Y no te olvides las bolsas... ya sabes para qué. ¡EXCELENTE!"';

    // Cargamos la primera localización aleatoria al abrir la página
    CargarLocalizacionAleatoria();
  end;

  // ===========================================================================
  // VARIABLES DE LA PÁGINA
  // ===========================================================================
  var
    // ── Texto de instrucción (fijo, no cambia) ────────────────────────────
    Instruccion: Text[500];

    // ── Datos de la localización (cambian en cada "Nuevo Paseo") ──────────
    NombreLugar: Text[100];    // Nombre del lugar (ej: "Moe's Tavern")
    Ciudad: Text[100];         // Ciudad (normalmente "Springfield")
    UsoLugar: Text[100];       // Tipo de uso (ej: "Bar", "Education", "Zoo")
    ImagenUrl: Text[250];      // URL completa de la imagen del lugar

    // ── Variables de control UI ──────────────────────────────────────────────────
    LugarCargado: Boolean;     // Controla la visibilidad del grupo de imagen
    AddinReady: Boolean;       // True cuando el JavaScript del addin está cargado

  // ===========================================================================
  // PROCEDIMIENTOS LOCALES
  // ===========================================================================

  /// <summary>
  /// Llama al codeunit para obtener una nueva localización aleatoria y
  /// actualiza todas las variables de la página con los datos recibidos.
  /// </summary>
  local procedure CargarLocalizacionAleatoria()
  var
    SimpsonsAPI: Codeunit "Simpsons API";
    NombreTemp: Text;
    CiudadTemp: Text;
    UsoTemp: Text;
    ImagenTemp: Text;
  begin
    // Llamamos al codeunit con variables VAR para recibir los datos.
    // El codeunit genera el ID aleatorio internamente.
    SimpsonsAPI.GetRandomLocation(
      NombreTemp,
      CiudadTemp,
      UsoTemp,
      ImagenTemp
    );

    // Volcamos los datos a las variables de la página
    NombreLugar := CopyStr(NombreTemp, 1, MaxStrLen(NombreLugar));
    Ciudad := CopyStr(CiudadTemp, 1, MaxStrLen(Ciudad));
    UsoLugar := CopyStr(UsoTemp, 1, MaxStrLen(UsoLugar));
    ImagenUrl := CopyStr(ImagenTemp, 1, MaxStrLen(ImagenUrl));

    LugarCargado := true;

    // Forzamos el refresco visual de la página
    CurrPage.Update(false);

    // Enviamos la imagen al ControlAddin para mostrarla visualmente.
    // Solo lo hacemos si el addin ya está inicializado.
    // Si no está listo todavía (puede ocurrir en la primera carga desde OnOpenPage),
    // el trigger ControlAddinReady() enviará la imagen cuando el addin termine de cargar.
    if AddinReady then
      CurrPage.ImagenLugarAddin.DisplayPortrait(ImagenUrl, NombreLugar);
  end;
}

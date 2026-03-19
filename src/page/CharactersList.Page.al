// =============================================================================
// PÁGINA: Characters List (Lista de Personajes)
// OBJETO: Page 50001
// =============================================================================
// Propósito:
//   Muestra en una lista los personajes ya importados desde la API y guardados
//   en la tabla persistente "Characters". Permite:
//     - Ver el listado de personajes registrados en BC.
//     - Importar/Actualizar personajes desde la API (acción "Importar desde API").
//     - Abrir la ficha detallada de un personaje (Habitante de Springfield).
// =============================================================================

page 50001 "Characters List"
{
    Caption = 'Characters List';
    PageType = List;
    SourceTable = Characters;
    // UsageCategory y ApplicationArea hacen que la página aparezca
    // en la búsqueda (Tell Me / Ctrl+F3) de Business Central.
    UsageCategory = Lists;
    ApplicationArea = All;
    // Editable = false → la lista es solo de consulta, no se edita directamente.
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(CharactersRepeater)
            {
                field("ID Personaje"; Rec."ID Personaje")
                {
                    ApplicationArea = All;
                    ToolTip = 'Identificador único del personaje en la API de los Simpsons.';
                }
                field("Nombre Personaje"; Rec."Nombre Personaje")
                {
                    ApplicationArea = All;
                    ToolTip = 'Nombre completo del personaje de Springfield.';
                }
                field("Fecha Actualización"; Rec."Fecha Actualización")
                {
                    ApplicationArea = All;
                    ToolTip = 'Fecha y hora en que se importaron los datos de este personaje.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // -----------------------------------------------------------------------
            // Acción: Importar desde API
            // Llama al codeunit SimpsonsAPI para descargar los personajes de la API
            // y guardarlos en la tabla Characters.
            // -----------------------------------------------------------------------
            action(ImportarDesdeAPI)
            {
                Caption = 'Importar Personajes desde API';
                ApplicationArea = All;
                Image = Refresh;
                ToolTip = 'Descarga los personajes desde la API de los Simpsons y los guarda en BC.';
                // Promoted = true hace que el botón aparezca visible en la barra superior.
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    SimpsonsAPI: Codeunit "Simpsons API";
                begin
                    // Llamamos al codeunit que gestiona toda la comunicación con la API.
                    // Le pasamos la tabla como parámetro VAR para que la rellene.
                    SimpsonsAPI.ImportarPersonajes(Rec);
                    Message('¡Excelente! Personajes importados correctamente.');
                end;
            }

            // -----------------------------------------------------------------------
            // Acción: Ver Detalle del Personaje
            // Abre la página "Habitante de Springfield" para ver los datos completos
            // del personaje seleccionado, consultando en tiempo real la API.
            // -----------------------------------------------------------------------
            action(VerDetalle)
            {
                Caption = 'Ver Habitante de Springfield';
                ApplicationArea = All;
                Image = View;
                ToolTip = 'Abre la ficha detallada de este personaje consultando la API.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    HabitantePage: Page "Habitante de Springfield";
                begin
                    // Pasamos el nombre del personaje seleccionado a la página
                    // para que realice la búsqueda automáticamente al abrirse.
                    HabitantePage.EstablecerBusqueda(Rec."Nombre Personaje");
                    HabitantePage.Run();
                end;
            }
        }
    }
}

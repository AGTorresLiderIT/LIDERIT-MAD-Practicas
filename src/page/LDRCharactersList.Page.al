page 50000 "Characters List"
{
    ApplicationArea = All;
    Caption = 'Characters List';
    PageType = List;
    SourceTable = Characters;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ID Personaje"; Rec."ID Personaje")
                {
                    ToolTip = 'Specifies the value of the ID Personaje field.', Comment = '%';
                }
                field("Nombre Personaje"; Rec."Nombre Personaje")
                {
                    ToolTip = 'Specifies the value of the Nombre Personaje field.', Comment = '%';
                    ApplicationArea = All;
                    trigger OnDrillDown()
                    var
                        CharacterTemp: Page Habitante_de_Springfield;
                    begin
                        CharacterTemp.SeleccionarRegistro(Rec."ID Personaje");
                        CharacterTemp.Run();
                    end;
                }
                field("Fecha Actualizacion"; Rec."Fecha Actualizacion")
                {
                    ToolTip = 'Specifies the value of the Fecha Actualizacion field.', Comment = '%';
                }
                field("Frases"; Rec."Frases")
                {
                    ToolTip = 'Specifies the value of the Frases field.', Comment = '%';
                    Visible = false;
                }
                field("Localizacion"; Rec."Localizacion")
                {
                    ToolTip = 'Specifies the value of the Localizacion field.', Comment = '%';
                    Visible = false;
                }
                field("Población"; Rec."Poblacion")
                {
                    ToolTip = 'Specifies the value of the Población field.', Comment = '%';
                    Visible = false;
                }

            }
            usercontrol(Sonido; Fotos)
            {
                ApplicationArea = All;
                trigger ControlListo()
                begin
                end;
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(MostrarDatos)
            {
                Caption = 'MostrarDatosDeAPI';
                ApplicationArea = All;
                Image = Download;
                trigger OnAction()
                var
                    SimpsonsAPI: Codeunit Simpsons_API;
                    CharacterTemp: Record TemporalCharacters temporary;
                begin
                    SimpsonsAPI.GetCharacters(CharacterTemp, true);
                    CurrPage.Update();
                end;
            }
            action(LeerFrase)
            {
                Caption = 'LeerFrase';
                ApplicationArea = All;
                Image = VoidCheck;
                trigger OnAction()
                begin
                    if Rec.Frases <> '' then
                        CurrPage.Sonido.Speak(Rec.Frases)
                    else
                        Message('Este character no tiene una frase para leer');
                end;
            }
            action("Localizacion Aleatoria")
            {
                Caption = 'Localizacion Aleatoria';
                ApplicationArea = All;
                Image = Map;
                trigger OnAction()
                var
                    PaginaPaseo: Page Paseo_de_perros;
                begin
                    PaginaPaseo.RunModal();
                end;
            }
        }
    }
    trigger OnAfterGetRecord()

    begin
    end;
}

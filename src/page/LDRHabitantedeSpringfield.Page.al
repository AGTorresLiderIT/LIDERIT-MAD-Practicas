page 50001 Habitante_de_Springfield
{
    ApplicationArea = All;
    Caption = 'Habitante_de_Springfield';
    PageType = Card;
    SourceTable = TemporalCharacters;
    SourceTableTemporary = true;
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the value of the Id field.', Comment = '%';
                }
                field("Cumpleaños"; Rec."Cumpleaños")
                {
                    ToolTip = 'Specifies the value of the Cumpleaños field.', Comment = '%';
                }
                field(Edad; Rec.Edad)
                {
                    ToolTip = 'Specifies the value of the Edad field.', Comment = '%';
                }
                usercontrol(Fotos; Fotos)
                {
                    ApplicationArea = All;
                    trigger ControlListo()
                    begin
                    end;
                }
                field(Frases; Rec.Frases)
                {
                    ToolTip = 'Specifies the value of the Frases field.', Comment = '%';
                    MultiLine = true;
                }
                field(Genero; Rec.Genero)
                {
                    ToolTip = 'Specifies the value of the Genero field.', Comment = '%';
                }
                field(Nombre; Rec.Nombre)
                {
                    ToolTip = 'Specifies the value of the Nombre field.', Comment = '%';
                }
                field(Puesto; Rec.Puesto)
                {
                    ToolTip = 'Specifies the value of the Puesto field.', Comment = '%';
                }
            }
        }
    }
    var
        idseleccionado: Integer;

    procedure SeleccionarRegistro(IDS: Integer)
    begin
        idseleccionado := IDS;
    end;

    trigger OnOpenPage()
    var
        SimpsonsAPI: Codeunit Simpsons_API;
    begin
        SimpsonsAPI.GetCharacters(Rec, false);
        if Rec.Get(idseleccionado) then;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.Foto <> '' then
            CurrPage.Fotos.InsertarFoto(Rec.Foto);
    end;
}

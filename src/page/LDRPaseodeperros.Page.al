page 50002 Paseo_de_perros
{
    ApplicationArea = All;
    Caption = 'Paseo_de_perros';
    PageType = Card;
    SourceTable = TemporalPaseo_de_perros;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Localizacion; Rec.Localizacion)
                {
                    ToolTip = 'Specifies the value of the Localizacion field.', Comment = '%';
                }
                field(Poblacion; Rec.Poblacion)
                {
                    ToolTip = 'Specifies the value of the Poblacion field.', Comment = '%';
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        SimpsonsAPI: Codeunit Simpsons_API;
    begin
        Rec.Init();
        Rec.ID := 1;
        Rec.Insert();

        SimpsonsAPI.GetRandomLocation(Rec);
    end;
}

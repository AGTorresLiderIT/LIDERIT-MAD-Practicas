page 50203 LDRFichaCharactersTemp
{
    ApplicationArea = All;
    Caption = 'FichaCharactersTemp';
    PageType = Card;
    SourceTableTemporary = true;
    SourceTable = "LDRCaracterTemp";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(Nombre; Rec.Nombre)
                {
                    ToolTip = 'Specifies the value of the Nombre field.', Comment = '%';
                }
                field(Id; rec.Id)
                {
                    ToolTip = 'Specifies the value of the Id field.', Comment = '%';
                }
                field(Ocupacion; Rec.Ocupacion)
                {
                    ToolTip = 'Specifies the value of the Ocupacion field.', Comment = '%';
                }
                field(FrasesCelebres; Rec."Frases Celebres")
                {
                    ToolTip = 'Specifies the value of the FrasesCelebres field.', Comment = '%';
                }
            }
            usercontrol(ImageViewer; SimpsonsImageViewer)
            {
                ApplicationArea = All;
                trigger Control()
                begin
                    if Rec.Imagen <> '' then
                        CurrPage.ImageViewer.SetImageUrl(Rec.Imagen);
                end;
            }
        }
    }
}

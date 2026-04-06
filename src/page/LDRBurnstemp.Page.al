page 50204 LDRBurnstemp
{
    ApplicationArea = All;
    Caption = 'Localización Burns';
    PageType = Card;
    SourceTableTemporary = true;
    SourceTable = "LDRCaracterTemp";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Nombre; Rec.Localizacion)
                {
                    ToolTip = 'Specifies the value of the Nombre field.', Comment = '%';
                }
            }
        }
    }
}

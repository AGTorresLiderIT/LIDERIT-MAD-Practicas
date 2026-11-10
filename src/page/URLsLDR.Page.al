page 52003 "URLs_LDR"
{
    ApplicationArea = All;
    Caption = 'URLs';
    PageType = List;
    SourceTable = URLs_LDR;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {

                field(Enviar; Rec.Enviar)
                {
                    ToolTip = 'Specifies the value of the Enviar field.', Comment = '%';
                }
                field(Recibir; Rec.Recibir)
                {
                    ToolTip = 'Specifies the value of the Recibir field.', Comment = '%';
                }
                field(Frases; Rec.Frases)
                {
                    ToolTip = 'Specifies the value of the Recibir field.', Comment = '%';
                }
            }
        }
    }
}

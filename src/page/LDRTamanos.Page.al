page 50200 Tamanos
{
    ApplicationArea = All;
    Caption = 'Tamanos';
    PageType = List;
    SourceTable = LDRTamanos;
    UsageCategory = Lists;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Codigo; Rec.Codigo)
                {
                    ToolTip = 'Specifies the value of the Codigo field.', Comment = '%';
                }
                field("Tamaño"; Rec."Tamaño")
                {
                    ToolTip = 'Specifies the value of the Tamaño field.', Comment = '%';
                }
            }
        }
    }
}

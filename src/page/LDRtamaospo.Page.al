page 50001 "tamañospo"
{
    ApplicationArea = All;
    Caption = 'tamañospo';
    PageType = List;
    SourceTable = "Tamaños Pokemon";
    UsageCategory = Lists;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Tamaño"; Rec."Tamaño")
                {
                    ToolTip = 'Specifies the value of the Tamaño field.', Comment = '%';
                }
                field("Tamaño (cm)"; Rec."Tamaño (cm)")
                {
                    ToolTip = 'Specifies the value of the Tamaño (cm) field.', Comment = '%';
                }
            }
        }
    }
}

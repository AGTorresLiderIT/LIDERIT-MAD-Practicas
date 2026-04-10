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
                field("Tamañocm"; Rec."Tamañocm")
                {
                    ToolTip = 'Specifies the value of the Tamañocm field.', Comment = '%';
                }
            }
        }
    }
}

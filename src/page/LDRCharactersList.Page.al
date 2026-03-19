page 50201 "LDRCharacters List"
{
    ApplicationArea = All;
    Caption = 'Characters List';
    PageType = List;
    SourceTable = LDRCharacters;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Nombre; Rec.Nombre)
                {
                    ToolTip = 'Specifies the value of the Nombre field.', Comment = '%';
                }
                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the value of the Id field.', Comment = '%';
                }
            }
        }
    }
}

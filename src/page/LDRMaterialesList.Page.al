page 50000 "LDR_MaterialesList"
{
    ApplicationArea = All;
    Caption = 'Lista de Materiales';
    PageType = List;
    SourceTable = LDR_Materiales;
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
                field(Descripcion; Rec.Descripcion)
                {
                    ToolTip = 'Specifies the value of the Descripcion field.', Comment = '%';
                }
                field(Bloqueado; Rec.Bloqueado)
                {
                    ToolTip = 'Specifies the value of the Bloqueado field.', Comment = '%';
                }
            }
        }
    }
}

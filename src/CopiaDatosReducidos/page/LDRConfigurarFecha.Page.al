page 50023 ConfigurarFecha
{
    ApplicationArea = All;
    Caption = 'ConfigurarFecha';
    PageType = StandardDialog;
    SourceTable = ConfigurarFecha;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            field(FechaCongf; Rec.Fecha)
            {
                Caption = 'Fecha';
                trigger OnValidate()
                begin

                end;
            }
        }
    }
}

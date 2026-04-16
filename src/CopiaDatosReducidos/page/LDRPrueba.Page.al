page 50024 Prueba
{
    ApplicationArea = All;
    Caption = 'Prueba';
    PageType = List;
    SourceTable = Prueba;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Hola"; Rec.Hola)
                {
                    Caption = 'Hola';
                    ToolTip = 'h';
                    ApplicationArea = All;
                }
                field("Fecha"; Rec.Fecha)
                {
                    Caption = 'Fecha';
                    ToolTip = 'h';
                    ApplicationArea = All;
                }
            }
        }
    }
}

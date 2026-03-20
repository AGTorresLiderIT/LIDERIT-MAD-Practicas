page 50000 "Characters List"
{
    ApplicationArea = All;
    Caption = 'Characters List';
    PageType = List;
    SourceTable = Characters;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ID Personaje"; Rec."ID Personaje")
                {
                    ToolTip = 'Specifies the value of the ID Personaje field.', Comment = '%';
                }
                field("Nombre Personaje"; Rec."Nombre Personaje")
                {
                    ToolTip = 'Specifies the value of the Nombre Personaje field.', Comment = '%';
                }
                field("Fecha Actualizacion"; Rec."Fecha Actualizacion")
                {
                    ToolTip = 'Specifies the value of the Fecha Actualizacion field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(MostrarDatos)
            {
                Caption = 'MostrarDatos2';
                Image = Refresh;
                trigger OnAction()
                begin
                end;
            }
        }
    }
}

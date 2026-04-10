page 50000 Pokemon
{
    ApplicationArea = All;
    Caption = 'Pokemon';
    PageType = List;
    SourceTable = Pokemon;
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
                field(Tipo; Rec.Tipo)
                {
                    ToolTip = 'Specifies the value of the Tipo field.', Comment = '%';
                }
                field("Tamañocm"; Rec."Tamañocm")
                {
                    ToolTip = 'Specifies the value of the Tamaño (cm) field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Importar)
            {
                ApplicationArea = All;
                Caption = 'Importar';
                Image = Import;

                trigger OnAction()
                begin
                    xmlport.Run(50000, false, true);
                end;
            }
        }
    }
}
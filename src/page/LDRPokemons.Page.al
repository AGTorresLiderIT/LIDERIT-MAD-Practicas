
page 50201 Pokemons
{
    ApplicationArea = All;
    Caption = 'Pokemons';
    PageType = List;
    SourceTable = LDRPokemons;
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
                field(Tamano; Rec.Tamano)
                {
                    ToolTip = 'Specifies the value of the Tamano field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(LDRImportarPokemons)
            {
                ApplicationArea = All;
                Caption = 'Importar Pokemons';
                ToolTip = 'Importar Pokemons desde un archivo XML';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Import;

                trigger OnAction()
                begin
                    Xmlport.Run(50200, false, true);
                end;
            }
        }
    }
}

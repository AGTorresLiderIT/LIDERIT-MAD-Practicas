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
                field("Tamaño (cm)"; Rec."Tamaño (cm)")
                {
                    ToolTip = 'Specifies the value of the Tamaño (cm) field.', Comment = '%';
                }
            }
        }
    }
    /*actions
    {
        area(Processing)
        {
            action(Action1)
            {
                Caption = 'Action1';
                Image = Process;
                trigger OnAction()
                var
                    GenJnlLineBuffer: Record "Gen. Journal Line";
                    decAmount: Decimal;
                begin
                    if GenJnlLineBuffer.FindSet() then begin
                    end;
                end;
            }
        }
    }*/
}
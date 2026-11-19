page 50000 "Commission Entries_LDR"
{
    ApplicationArea = All;
    Caption = 'Commission Entries', Comment = 'ESP="Movimientos de comisión"';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Commission Entry_LDR";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("Posting Date"; Rec."Posting Date") { }
                field("Document Type"; Rec."Document Type") { }
                field("Document No."; Rec."Document No.") { }
                field("Document Line No."; Rec."Document Line No.") { }
                field("Salesperson Code"; Rec."Salesperson Code") { }
                field("Customer No."; Rec."Customer No.") { }
                field("Item No."; Rec."Item No.") { }
                field("Base Amount (LCY)"; Rec."Base Amount (LCY)") { }
                field("Commission %"; Rec."Commission %") { }
                field("Commission Amount (LCY)"; Rec."Commission Amount (LCY)") { }
                field(Liquidated; Rec.Liquidated) { }
                field("Liquidation No."; Rec."Liquidation No.") { }
                field("User ID"; Rec."User ID") { }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Navigate)
            {
                Caption = 'Find entries...', Comment = 'ESP="Navegar..."';
                Image = Navigate;
                ShortcutKey = 'Ctrl+Alt+Q';
                ToolTip = 'Find entries and documents that exist for the document number and posting date of the selected entry.', Comment = 'ESP="Busca los movimientos y documentos que existen para el número de documento y la fecha de registro del movimiento seleccionado."';

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run();
                end;
            }
        }
        area(Promoted)
        {
            actionref(Navigate_Promoted; Navigate) { }
        }
    }
}

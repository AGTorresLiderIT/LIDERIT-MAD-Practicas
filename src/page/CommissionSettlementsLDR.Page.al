page 50003 "Commission Settlements_LDR"
{
    ApplicationArea = All;
    Caption = 'Commission Settlements', Comment = 'ESP="Liquidaciones de comisiones"';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Commission Settlement_LDR";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Settlements)
            {
                field("No."; Rec."No.") { }
                field("Salesperson Code"; Rec."Salesperson Code") { }
                field("Settlement Date"; Rec."Settlement Date") { }
                field("Up To Date"; Rec."Up To Date") { }
                field("Total Amount (LCY)"; Rec."Total Amount (LCY)") { }
                field("No. of Entries"; Rec."No. of Entries") { }
                field("Purchase Invoice No."; Rec."Purchase Invoice No.") { }
            }
        }
    }
    actions
    {
        area(Navigation)
        {
            action(Entries)
            {
                Caption = 'Entries', Comment = 'ESP="Movimientos"';
                Image = Entries;
                RunObject = page "Commission Entries_LDR";
                RunPageLink = "Liquidation No." = field("No.");
                ToolTip = 'View the commission entries included in the selected settlement.', Comment = 'ESP="Muestra los movimientos de comisión incluidos en la liquidación seleccionada."';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(Entries_Promoted; Entries) { }
            }
        }
    }
}

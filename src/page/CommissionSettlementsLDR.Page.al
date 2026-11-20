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
        area(Processing)
        {
            action(SettleCommissions)
            {
                Caption = 'Settle Commissions', Comment = 'ESP="Liquidar comisiones"';
                Image = CalculateCost;
                RunObject = report "Settle Commissions_LDR";
                ToolTip = 'Settle the pending commission entries of the salespeople up to a date.', Comment = 'ESP="Liquida los movimientos de comisión pendientes de los vendedores hasta una fecha."';
            }
            action(UndoSettlement)
            {
                Caption = 'Undo Settlement', Comment = 'ESP="Deshacer liquidación"';
                Image = Undo;
                ToolTip = 'Undo the selected settlement: its draft purchase invoice is deleted and its commission entries become pending again.', Comment = 'ESP="Deshace la liquidación seleccionada: se elimina su factura de compra borrador y sus movimientos de comisión vuelven a quedar pendientes."';

                trigger OnAction()
                var
                    CommissionMgt: Codeunit "Commission Mgt._LDR";
                begin
                    if Rec."Purchase Invoice No." <> '' then begin
                        if not Confirm(UndoSettlementQst, false, Rec."No.", Rec."Purchase Invoice No.") then
                            exit;
                    end else
                        if not Confirm(UndoSettlementNoInvoiceQst, false, Rec."No.") then
                            exit;
                    CommissionMgt.UndoSettlement(Rec."No.");
                end;
            }
        }
        area(Reporting)
        {
            action(Print)
            {
                Caption = 'Print', Comment = 'ESP="Imprimir"';
                Ellipsis = true;
                Image = Print;
                ToolTip = 'Print the selected commission settlement.', Comment = 'ESP="Imprime la liquidación de comisiones seleccionada."';

                trigger OnAction()
                var
                    CommissionSettlement: Record "Commission Settlement_LDR";
                begin
                    // RF-5.3: only the selected settlement, on a copy so that the filters of the page do not change.
                    CommissionSettlement := Rec;
                    CommissionSettlement.SetRecFilter();
                    Report.Run(Report::"Commission Settlement_LDR", true, false, CommissionSettlement);
                end;
            }
        }
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
                actionref(SettleCommissions_Promoted; SettleCommissions) { }
                actionref(UndoSettlement_Promoted; UndoSettlement) { }
                actionref(Entries_Promoted; Entries) { }
            }
            group(Category_Report)
            {
                actionref(Print_Promoted; Print) { }
            }
        }
    }

    var
        UndoSettlementQst: Label 'Do you want to undo settlement %1? Draft purchase invoice %2 will be deleted and the commission entries will be pending again.', Comment = 'ESP="¿Desea deshacer la liquidación %1? Se eliminará la factura de compra borrador %2 y los movimientos volverán a quedar pendientes." %1 = settlement no., %2 = purchase invoice no.';
        UndoSettlementNoInvoiceQst: Label 'Do you want to undo settlement %1? The commission entries will be pending again.', Comment = 'ESP="¿Desea deshacer la liquidación %1? Los movimientos volverán a quedar pendientes." %1 = settlement no.';
}

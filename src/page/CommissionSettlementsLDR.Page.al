page 50003 "Commission Settlements_LDR"
{
    ApplicationArea = All;
    Caption = 'Commission Settlements', Comment = 'ESP="Liquidaciones de comisiones"';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Comm. Settlement_LDR";
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
                RunObject = report "Settle Salesp. Commissions_LDR";
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
            // TF0023 RF-4.1: creates the recurring job queue entry if it does not exist yet.
            action(ScheduleAutomaticSettlement)
            {
                Caption = 'Schedule Automatic Settlement', Comment = 'ESP="Programar liquidación automática"';
                Image = Timesheet;
                ToolTip = 'Create the job queue entry that settles the commissions on day 1 of every month at 02:00, if it does not exist yet.', Comment = 'ESP="Crea la entrada de la cola de proyectos que liquida las comisiones el día 1 de cada mes a las 02:00, si no existe ya."';

                trigger OnAction()
                var
                    CommissionMgt: Codeunit "Commission Mgt._LDR";
                    EarliestStartDateTime: DateTime;
                begin
                    if CommissionMgt.ScheduleAutomaticSettlement(EarliestStartDateTime) then
                        Message(ScheduledMsg, EarliestStartDateTime)
                    else
                        Message(AlreadyScheduledMsg);
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
                    CommissionSettlement: Record "Comm. Settlement_LDR";
                begin
                    // RF-5.3: only the selected settlement, on a copy so that the filters of the page do not change.
                    CommissionSettlement := Rec;
                    CommissionSettlement.SetRecFilter();
                    Report.Run(Report::"Comm. Settlement_LDR", true, false, CommissionSettlement);
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
            // TF0023 RF-2.2: log of the automatic settlement.
            action(ProcessLog)
            {
                Caption = 'Process Log', Comment = 'ESP="Registro del proceso"';
                Image = Log;
                RunObject = page "Commission Process Log_LDR";
                ToolTip = 'View the log of the automatic commission settlement.', Comment = 'ESP="Muestra el registro de la liquidación automática de comisiones."';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(SettleCommissions_Promoted; SettleCommissions) { }
                actionref(UndoSettlement_Promoted; UndoSettlement) { }
                actionref(ScheduleAutomaticSettlement_Promoted; ScheduleAutomaticSettlement) { }
                actionref(Entries_Promoted; Entries) { }
                actionref(ProcessLog_Promoted; ProcessLog) { }
            }
            group(Category_Report)
            {
                actionref(Print_Promoted; Print) { }
            }
        }
    }

    var
        UndoSettlementQst: Label 'Do you want to undo settlement %1? Draft purchase invoice %2 will be deleted and the commission entries will be pending again.', Comment = 'ESP="¿Desea deshacer la liquidación %1? Se eliminará la factura de compra borrador %2 y los movimientos volverán a quedar pendientes." %1 = settlement no., %2 = purchase invoice no.';
        ScheduledMsg: Label 'The automatic settlement has been scheduled for %1.', Comment = 'ESP="La liquidación automática se ha programado para el %1." %1 = earliest start date and time';
        AlreadyScheduledMsg: Label 'The automatic settlement is already scheduled. You can review it in Job Queue Entries.', Comment = 'ESP="La liquidación automática ya está programada. Puede revisarla en Movs. cola proyectos."';
        UndoSettlementNoInvoiceQst: Label 'Do you want to undo settlement %1? The commission entries will be pending again.', Comment = 'ESP="¿Desea deshacer la liquidación %1? Los movimientos volverán a quedar pendientes." %1 = settlement no.';
}

report 50000 "Settle Salesp. Commissions_LDR"
{
    ApplicationArea = All;
    Caption = 'Settle Commissions', Comment = 'ESP="Liquidar comisiones"';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        dataitem(SalespersonPurchaser; "Salesperson/Purchaser")
        {
            DataItemTableView = sorting(Code);
            RequestFilterFields = Code;

            trigger OnAfterGetRecord()
            var
                CommissionSettlement: Record "Comm. Settlement_LDR";
                SettleSalespersonCommission: Codeunit "Salesp. Comm. Settlement_LDR";
                SettlementNo: Code[20];
                Warning: Text;
            begin
                if GuiAllowed() then
                    ProgressWindow.Update(1, SalespersonPurchaser.Code);

                // P-4: all or nothing. Codeunit.Run without "if" and without Commit: an error in one salesperson
                // rolls back the whole process and the user sees it.
                Clear(SettleSalespersonCommission);
                SettleSalespersonCommission.SetParameters(UpToDate, CreatePurchaseInvoice);
                SettleSalespersonCommission.Run(SalespersonPurchaser);

                // RF-3.2: the codeunit does not create a settlement when there are no pending entries.
                SettlementNo := SettleSalespersonCommission.GetSettlementNo();
                if SettlementNo = '' then
                    CurrReport.Skip();

                NoOfSettlements += 1;
                CommissionSettlement.SetAutoCalcFields("Total Amount (LCY)");
                CommissionSettlement.Get(SettlementNo);
                TotalAmountLCY += CommissionSettlement."Total Amount (LCY)";

                Warning := SettleSalespersonCommission.GetWarningText();
                if Warning <> '' then begin
                    NoOfWarnings += 1;
                    Warnings.AppendLine(Warning);
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = false;

        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options', Comment = 'ESP="Opciones"';

                    field(UpToDateField; UpToDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Up To Date', Comment = 'ESP="Fecha hasta"';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the posting date up to which the pending commission entries are settled.', Comment = 'ESP="Especifica la fecha de registro hasta la que se liquidan los movimientos de comisión pendientes."';
                    }
                    field(CreatePurchaseInvoiceField; CreatePurchaseInvoice)
                    {
                        ApplicationArea = All;
                        Caption = 'Create Purchase Invoice', Comment = 'ESP="Crear factura de compra"';
                        ToolTip = 'Specifies whether a draft purchase invoice is created to the vendor of each salesperson for the settled total.', Comment = 'ESP="Especifica si se crea una factura de compra borrador al proveedor de cada vendedor por el total liquidado."';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            // RF-3.1 (P-2): by default, the last day of the month before the work date.
            if UpToDate = 0D then
                UpToDate := CalcDate('<-CM-1D>', WorkDate());
        end;
    }

    trigger OnPreReport()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        if UpToDate = 0D then
            Error(UpToDateMissingErr);
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Commission Settlement Nos._LDR");
        if CreatePurchaseInvoice then
            SalesReceivablesSetup.TestField("Commission Account_LDR");

        // RF-3.5: progress and final message only with a user interface (scheduled runs show nothing).
        if GuiAllowed() then
            ProgressWindow.Open(ProgressMsg);
    end;

    trigger OnPostReport()
    var
        FinalMessage: Text;
    begin
        if not GuiAllowed() then
            exit;

        ProgressWindow.Close();
        FinalMessage := StrSubstNo(FinishedMsg, NoOfSettlements, Format(TotalAmountLCY, 0, '<Precision,2:2><Standard Format,0>'), NoOfWarnings);
        if NoOfWarnings > 0 then
            FinalMessage += '\' + Warnings.ToText();
        Message('%1', FinalMessage);
    end;

    var
        UpToDate: Date;
        CreatePurchaseInvoice: Boolean;
        ProgressWindow: Dialog;
        NoOfSettlements: Integer;
        NoOfWarnings: Integer;
        TotalAmountLCY: Decimal;
        Warnings: TextBuilder;
        UpToDateMissingErr: Label 'Specify the up-to date.', Comment = 'ESP="Indique la fecha hasta."';
        ProgressMsg: Label 'Settling salesperson #1##########', Comment = 'ESP="Liquidando vendedor #1##########"';
        FinishedMsg: Label '%1 settlements have been created for a total of %2. Warnings: %3', Comment = 'ESP="Se han creado %1 liquidaciones por un total de %2. Avisos: %3" %1 = number of settlements, %2 = total amount, %3 = number of warnings';
}

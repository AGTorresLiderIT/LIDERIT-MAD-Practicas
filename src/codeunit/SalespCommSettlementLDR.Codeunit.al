codeunit 50002 "Settle Salesp. Commission_LDR"
{
    // RF-3.6 (P-3): settles one salesperson. No Message, Confirm, Dialog or Commit: the manual report (TF0021) and the
    // job queue (TF0023) share it. The caller runs Clear on the instance before each salesperson and then SetParameters.
    // P-4: errors are normal errors; the caller decides whether they roll back the whole process or only this salesperson.
    Permissions = tabledata "Commission Entry_LDR" = rm,
                  tabledata "Commission Settlement_LDR" = rim;
    TableNo = "Salesperson/Purchaser";

    var
        UpToDate: Date;
        CreatePurchaseInvoice: Boolean;
        SettlementNo: Code[20];
        WarningText: Text;
        UpToDateMissingErr: Label 'Specify the up-to date.', Comment = 'ESP="Indique la fecha hasta."';
        NoVendorMsg: Label 'Salesperson %1 has no vendor: settlement %2 has been created without an invoice.', Comment = 'ESP="El vendedor %1 no tiene proveedor: la liquidación %2 se ha creado sin factura." %1 = salesperson code, %2 = settlement no.';
        VendorNotValidMsg: Label 'Vendor %1 of salesperson %2 is blocked or has a currency: settlement %3 has been created without an invoice.', Comment = 'ESP="El proveedor %1 del vendedor %2 está bloqueado o tiene divisa: la liquidación %3 se ha creado sin factura." %1 = vendor no., %2 = salesperson code, %3 = settlement no.';
        NonPositiveTotalMsg: Label 'Settlement %1 has a total of %2: no purchase invoice is created.', Comment = 'ESP="La liquidación %1 tiene un total de %2: no se crea factura de compra." %1 = settlement no., %2 = total amount';

    trigger OnRun()
    var
        CommissionEntry: Record "Commission Entry_LDR";
        CommissionSettlement: Record "Commission Settlement_LDR";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        TotalAmountLCY: Decimal;
    begin
        SettlementNo := '';
        WarningText := '';

        // P-3: the codeunit checks the setup itself because TF0023 runs it without the report.
        if UpToDate = 0D then
            Error(UpToDateMissingErr);
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Commission Settlement Nos._LDR");
        if CreatePurchaseInvoice then
            SalesReceivablesSetup.TestField("Commission Account_LDR");

        // RF-3.2: pending entries of the salesperson up to the date. LockTable before reading so that two sessions
        // cannot settle the same entries: the second one waits and then finds nothing pending.
        CommissionEntry.SetCurrentKey("Salesperson Code", Liquidated, "Posting Date");
        CommissionEntry.SetRange("Salesperson Code", Rec.Code);
        CommissionEntry.SetRange(Liquidated, false);
        CommissionEntry.SetRange("Posting Date", 0D, UpToDate);
        CommissionEntry.LockTable();
        if CommissionEntry.IsEmpty() then
            exit;
        CommissionEntry.CalcSums("Commission Amount (LCY)");
        TotalAmountLCY := CommissionEntry."Commission Amount (LCY)";

        CommissionSettlement.Init();
        CommissionSettlement."Salesperson Code" := Rec.Code;
        CommissionSettlement."Settlement Date" := WorkDate();
        CommissionSettlement."Up To Date" := UpToDate;
        CommissionSettlement.Insert(true);

        // RF-3.3 (P-1): "Liquidation No." first. Liquidated is part of the filter: if it were changed first,
        // the entries would leave the filter and the second ModifyAll would not modify anything.
        CommissionEntry.ModifyAll("Liquidation No.", CommissionSettlement."No.");
        CommissionEntry.ModifyAll(Liquidated, true);

        if CreatePurchaseInvoice then
            CreateInvoice(CommissionSettlement, Rec, TotalAmountLCY, SalesReceivablesSetup."Commission Account_LDR");

        SettlementNo := CommissionSettlement."No.";
    end;

    procedure SetParameters(NewUpToDate: Date; NewCreatePurchaseInvoice: Boolean)
    begin
        UpToDate := NewUpToDate;
        CreatePurchaseInvoice := NewCreatePurchaseInvoice;
    end;

    procedure GetSettlementNo(): Code[20]
    begin
        exit(SettlementNo);
    end;

    procedure GetWarningText(): Text
    begin
        exit(WarningText);
    end;

    // RF-3.4: draft purchase invoice to the vendor of the salesperson for the total. Without a valid vendor or with a
    // total <= 0 the settlement stays without invoice and a warning is returned, without error (P-8).
    local procedure CreateInvoice(var CommissionSettlement: Record "Commission Settlement_LDR"; SalespersonPurchaser: Record "Salesperson/Purchaser"; TotalAmountLCY: Decimal; CommissionAccountNo: Code[20])
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        if (SalespersonPurchaser."Vendor No._LDR" = '') or not Vendor.Get(SalespersonPurchaser."Vendor No._LDR") then begin
            WarningText := StrSubstNo(NoVendorMsg, SalespersonPurchaser.Code, CommissionSettlement."No.");
            exit;
        end;
        if (Vendor.Blocked <> Vendor.Blocked::" ") or (Vendor."Currency Code" <> '') then begin
            WarningText := StrSubstNo(VendorNotValidMsg, Vendor."No.", SalespersonPurchaser.Code, CommissionSettlement."No.");
            exit;
        end;
        if TotalAmountLCY <= 0 then begin
            WarningText := StrSubstNo(NonPositiveTotalMsg, CommissionSettlement."No.", Format(TotalAmountLCY, 0, '<Precision,2:2><Standard Format,0>'));
            exit;
        end;

        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Invoice;
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", Vendor."No.");
        // P-8: the total is a net amount.
        if PurchaseHeader."Prices Including VAT" then
            PurchaseHeader.Validate("Prices Including VAT", false);
        PurchaseHeader.Validate("Vendor Invoice No.", CommissionSettlement."No.");
        PurchaseHeader.Modify(true);

        PurchaseLine.Init();
        PurchaseLine."Document Type" := PurchaseHeader."Document Type";
        PurchaseLine."Document No." := PurchaseHeader."No.";
        PurchaseLine."Line No." := 10000;
        PurchaseLine.Validate(Type, PurchaseLine.Type::"G/L Account");
        PurchaseLine.Validate("No.", CommissionAccountNo);
        PurchaseLine.Validate(Quantity, 1);
        PurchaseLine.Validate("Direct Unit Cost", TotalAmountLCY);
        PurchaseLine.Insert(true);

        CommissionSettlement."Purchase Invoice No." := PurchaseHeader."No.";
        CommissionSettlement.Modify();
    end;
}

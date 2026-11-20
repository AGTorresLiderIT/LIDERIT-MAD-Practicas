codeunit 50000 "Commission Mgt._LDR"
{
    // Runs inside the sales posting transaction: no Commit, Message or Confirm, and it never raises an error
    // because of the commission (if a condition is not met it exits without creating the entry).
    // UndoSettlement (TF0021) is called from the settlements list after the user confirms.
    Permissions = tabledata "Commission Entry_LDR" = rim,
                  tabledata "Commission Settlement_LDR" = rd;

    procedure CreateFromSalesInvLine(SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header")
    begin
        if SalesInvLine.Type <> SalesInvLine.Type::Item then
            exit;

        CreateEntry(
            "Commission Document Type_LDR"::Invoice, SalesInvHeader."Posting Date", SalesInvLine."Document No.", SalesInvLine."Line No.",
            SalesInvHeader."Salesperson Code", SalesInvHeader."Sell-to Customer No.", SalesInvLine."No.", SalesInvLine.Quantity,
            SalesInvLine.Amount, SalesInvHeader."Currency Code", SalesInvHeader."Currency Factor", 1);
    end;

    procedure CreateFromSalesCrMemoLine(SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if SalesCrMemoLine.Type <> SalesCrMemoLine.Type::Item then
            exit;

        CreateEntry(
            "Commission Document Type_LDR"::"Credit Memo", SalesCrMemoHeader."Posting Date", SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.",
            SalesCrMemoHeader."Salesperson Code", SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoLine."No.", SalesCrMemoLine.Quantity,
            SalesCrMemoLine.Amount, SalesCrMemoHeader."Currency Code", SalesCrMemoHeader."Currency Factor", -1);
    end;

    local procedure CreateEntry(DocumentType: Enum "Commission Document Type_LDR"; PostingDate: Date; DocumentNo: Code[20]; DocumentLineNo: Integer; SalespersonCode: Code[20]; CustomerNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; Amount: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; Sign: Integer)
    var
        CommissionEntry: Record "Commission Entry_LDR";
        CommissionPct: Decimal;
        BaseAmountLCY: Decimal;
    begin
        // P-4: no entries during the posting preview.
        if IsPostingPreview() then
            exit;
        // S-01 (RF-3.1): only lines with quantity greater than 0. Credit memo lines also come with positive quantity.
        if Quantity <= 0 then
            exit;
        if IsItemExcluded(ItemNo) then
            exit;
        // RF-3.3: no salesperson or 0 % means no entry and no error.
        CommissionPct := GetCommissionPct(SalespersonCode);
        if CommissionPct = 0 then
            exit;

        BaseAmountLCY := GetBaseAmountLCY(PostingDate, Amount, CurrencyCode, CurrencyFactor);

        CommissionEntry.Init();
        CommissionEntry."Entry No." := 0; // P-1: AutoIncrement, the database assigns the number.
        CommissionEntry."Posting Date" := PostingDate;
        CommissionEntry."Document Type" := DocumentType;
        CommissionEntry."Document No." := DocumentNo;
        CommissionEntry."Document Line No." := DocumentLineNo;
        CommissionEntry."Salesperson Code" := SalespersonCode;
        CommissionEntry."Customer No." := CustomerNo;
        CommissionEntry."Item No." := ItemNo;
        CommissionEntry."Commission %" := CommissionPct;
        // RF-3.2: the sign is applied after converting and rounding.
        CommissionEntry."Base Amount (LCY)" := Sign * BaseAmountLCY;
        CommissionEntry."Commission Amount (LCY)" := Sign * CalcCommissionAmount(BaseAmountLCY, CommissionPct);
        CommissionEntry."User ID" := CopyStr(UserId(), 1, MaxStrLen(CommissionEntry."User ID"));
        CommissionEntry.Insert(true);
    end;

    local procedure IsPostingPreview(): Boolean
    var
        GenJnlPostPreview: Codeunit "Gen. Jnl.-Post Preview";
    begin
        exit(GenJnlPostPreview.IsActive());
    end;

    local procedure IsItemExcluded(ItemNo: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("Exclude from Commission_LDR");
        if not Item.Get(ItemNo) then
            exit(true);
        exit(Item."Exclude from Commission_LDR");
    end;

    local procedure GetCommissionPct(SalespersonCode: Code[20]): Decimal
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        if SalespersonCode = '' then
            exit(0);
        SalespersonPurchaser.SetLoadFields("Commission %");
        if not SalespersonPurchaser.Get(SalespersonCode) then
            exit(0);
        exit(SalespersonPurchaser."Commission %");
    end;

    // RF-3.4 / P-3: line amount without VAT converted to local currency like the standard, rounded with the
    // amount rounding precision of the general ledger setup.
    local procedure GetBaseAmountLCY(PostingDate: Date; Amount: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal): Decimal
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if CurrencyCode = '' then
            exit(Round(Amount, GeneralLedgerSetup."Amount Rounding Precision"));
        exit(
            Round(
                CurrencyExchangeRate.ExchangeAmtFCYToLCY(PostingDate, CurrencyCode, Amount, CurrencyFactor),
                GeneralLedgerSetup."Amount Rounding Precision"));
    end;

    // RF-4.1 / P-6: the line is only added if the user can read the commission entries.
    procedure FindNavigateEntries(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        CommissionEntry: Record "Commission Entry_LDR";
    begin
        if not CommissionEntry.ReadPermission() then
            exit;
        SetNavigateFilters(CommissionEntry, DocNoFilter, PostingDateFilter);
        DocumentEntry.InsertIntoDocEntry(Database::"Commission Entry_LDR", CommissionEntry.TableCaption(), CommissionEntry.Count());
    end;

    procedure ShowNavigateEntries(var TempDocumentEntry: Record "Document Entry" temporary; DocNoFilter: Text; PostingDateFilter: Text; var IsHandled: Boolean)
    var
        CommissionEntry: Record "Commission Entry_LDR";
    begin
        if IsHandled or (TempDocumentEntry."Table ID" <> Database::"Commission Entry_LDR") then
            exit;
        SetNavigateFilters(CommissionEntry, DocNoFilter, PostingDateFilter);
        Page.Run(Page::"Commission Entries_LDR", CommissionEntry);
        IsHandled := true;
    end;

    local procedure SetNavigateFilters(var CommissionEntry: Record "Commission Entry_LDR"; DocNoFilter: Text; PostingDateFilter: Text)
    begin
        CommissionEntry.SetCurrentKey("Document No.", "Posting Date");
        CommissionEntry.SetFilter("Document No.", DocNoFilter);
        CommissionEntry.SetFilter("Posting Date", PostingDateFilter);
    end;

    // TF0021 RF-4.1 / RF-4.2: undoes a commission settlement. No Confirm here: the action of the page asks first.
    procedure UndoSettlement(SettlementNo: Code[20])
    var
        CommissionEntry: Record "Commission Entry_LDR";
        CommissionSettlement: Record "Commission Settlement_LDR";
        PurchaseHeader: Record "Purchase Header";
    begin
        // Lock and read again so that two users cannot undo the same settlement at the same time.
        CommissionSettlement.LockTable();
        CommissionSettlement.Get(SettlementNo);

        if CommissionSettlement."Purchase Invoice No." <> '' then
            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Invoice, CommissionSettlement."Purchase Invoice No.") then
                PurchaseHeader.Delete(true) // The OnDelete trigger of the header also deletes its lines.
            else
                // RF-4.1 (P-5): not in Purchase Header. If it was posted, it is found by "Pre-Assigned No.";
                // if it was deleted by hand, the settlement can be undone.
                if IsPurchaseInvoicePosted(CommissionSettlement."Purchase Invoice No.") then
                    Error(InvoicePostedErr, CommissionSettlement."Purchase Invoice No.", CommissionSettlement."No.");

        // RF-4.2 (P-1): the filter is "Liquidation No.", so Liquidated first and "Liquidation No." last.
        CommissionEntry.SetCurrentKey("Liquidation No.");
        CommissionEntry.SetRange("Liquidation No.", CommissionSettlement."No.");
        CommissionEntry.ModifyAll(Liquidated, false);
        CommissionEntry.ModifyAll("Liquidation No.", '');

        CommissionSettlement.Delete();
    end;

    local procedure IsPurchaseInvoicePosted(PurchaseInvoiceNo: Code[20]): Boolean
    var
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        PurchInvHeader.SetCurrentKey("Pre-Assigned No.");
        PurchInvHeader.SetRange("Pre-Assigned No.", PurchaseInvoiceNo);
        exit(not PurchInvHeader.IsEmpty());
    end;

    local procedure CalcCommissionAmount(BaseAmountLCY: Decimal; CommissionPct: Decimal): Decimal
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        exit(Round(BaseAmountLCY * CommissionPct / 100, GeneralLedgerSetup."Amount Rounding Precision"));
    end;

    var
        InvoicePostedErr: Label 'Purchase invoice %1 of settlement %2 has already been posted. The settlement cannot be undone.', Comment = 'ESP="La factura de compra %1 de la liquidación %2 ya está registrada. No se puede deshacer la liquidación." %1 = purchase invoice no., %2 = settlement no.';
}

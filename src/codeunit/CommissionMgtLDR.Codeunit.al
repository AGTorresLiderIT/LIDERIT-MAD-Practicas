codeunit 50000 "Commission Mgt._LDR"
{
    // Runs inside the sales posting transaction: no Commit, Message or Confirm, and it never raises an error
    // because of the commission (if a condition is not met it exits without creating the entry).
    // UndoSettlement (TF0021) is called from the settlements list after the user confirms.
    Permissions = tabledata "Commission Entry_LDR" = rim,
                  tabledata "Comm. Settlement_LDR" = rd,
                  tabledata "Commission Rate_LDR" = r;

    procedure CreateFromSalesInvLine(SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header")
    begin
        if SalesInvLine.Type <> SalesInvLine.Type::Item then
            exit;

        CreateEntry(
            "Commission Document Type_LDR"::Invoice, SalesInvHeader."Posting Date", SalesInvLine."Document No.", SalesInvLine."Line No.",
            SalesInvHeader."Salesperson Code", SalesInvHeader."Sell-to Customer No.", SalesInvLine."No.", SalesInvLine.Quantity,
            SalesInvLine.Amount, SalesInvHeader."Currency Code", SalesInvHeader."Currency Factor", 1, '');
    end;

    procedure CreateFromSalesCrMemoLine(SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    begin
        if SalesCrMemoLine.Type <> SalesCrMemoLine.Type::Item then
            exit;

        CreateEntry(
            "Commission Document Type_LDR"::"Credit Memo", SalesCrMemoHeader."Posting Date", SalesCrMemoLine."Document No.", SalesCrMemoLine."Line No.",
            SalesCrMemoHeader."Salesperson Code", SalesCrMemoHeader."Sell-to Customer No.", SalesCrMemoLine."No.", SalesCrMemoLine.Quantity,
            SalesCrMemoLine.Amount, SalesCrMemoHeader."Currency Code", SalesCrMemoHeader."Currency Factor", -1,
            GetOriginalInvoiceNo(SalesCrMemoHeader));
    end;

    // TF0022 RF-2.1 (P1): the credit memo uses the % of the original invoice. It is found by "Applies-to Doc. No."
    // and, if that is blank, by "Corrected Invoice No." (corrective credit memos).
    local procedure GetOriginalInvoiceNo(SalesCrMemoHeader: Record "Sales Cr.Memo Header"): Code[20]
    begin
        if (SalesCrMemoHeader."Applies-to Doc. Type" = SalesCrMemoHeader."Applies-to Doc. Type"::Invoice) and
           (SalesCrMemoHeader."Applies-to Doc. No." <> '')
        then
            exit(SalesCrMemoHeader."Applies-to Doc. No.");
        exit(SalesCrMemoHeader."Corrected Invoice No.");
    end;

    local procedure CreateEntry(DocumentType: Enum "Commission Document Type_LDR"; PostingDate: Date; DocumentNo: Code[20]; DocumentLineNo: Integer; SalespersonCode: Code[20]; CustomerNo: Code[20]; ItemNo: Code[20]; Quantity: Decimal; Amount: Decimal; CurrencyCode: Code[10]; CurrencyFactor: Decimal; Sign: Integer; OriginalInvoiceNo: Code[20])
    var
        CommissionEntry: Record "Commission Entry_LDR";
        ItemCategoryCode: Code[20];
        CommissionPct: Decimal;
        BaseAmountLCY: Decimal;
    begin
        // P-4: no entries during the posting preview.
        if IsPostingPreview() then
            exit;
        // S-01 (RF-3.1): only lines with quantity greater than 0. Credit memo lines also come with positive quantity.
        if Quantity <= 0 then
            exit;
        if IsItemExcluded(ItemNo, ItemCategoryCode) then
            exit;
        // RF-3.3: no salesperson or 0 % means no entry and no error.
        // TF0022 RF-2.2 / P-2: only the way to get the % changes; a rate with 0 % also means no entry.
        if not GetOriginalInvoicePct(OriginalInvoiceNo, ItemNo, CommissionPct) then
            CommissionPct := GetCommissionPct(SalespersonCode, ItemCategoryCode, PostingDate);
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

    // TF0022 P-2: the item category is read from the item card in the same read as the exclusion flag.
    local procedure IsItemExcluded(ItemNo: Code[20]; var ItemCategoryCode: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("Exclude from Commission_LDR", "Item Category Code");
        if not Item.Get(ItemNo) then
            exit(true);
        ItemCategoryCode := Item."Item Category Code";
        exit(Item."Exclude from Commission_LDR");
    end;

    // TF0022 RF-2.1 (P1): % of the commission entry of the same item in the original invoice. If there is no
    // original invoice or it has no entry, the rate in force on the credit memo date is used.
    local procedure GetOriginalInvoicePct(OriginalInvoiceNo: Code[20]; ItemNo: Code[20]; var CommissionPct: Decimal): Boolean
    var
        CommissionEntry: Record "Commission Entry_LDR";
    begin
        if OriginalInvoiceNo = '' then
            exit(false);
        CommissionEntry.SetCurrentKey("Document No.", "Posting Date");
        CommissionEntry.SetRange("Document No.", OriginalInvoiceNo);
        CommissionEntry.SetRange("Document Type", CommissionEntry."Document Type"::Invoice);
        CommissionEntry.SetRange("Item No.", ItemNo);
        CommissionEntry.SetLoadFields("Commission %");
        if not CommissionEntry.FindFirst() then
            exit(false);
        CommissionPct := CommissionEntry."Commission %";
        exit(true);
    end;

    // TF0022 RF-2.1: rate of the salesperson and item category in force on the posting date, then the rate of
    // the salesperson with a blank category, then the "Commission %" of the salesperson card.
    local procedure GetCommissionPct(SalespersonCode: Code[20]; ItemCategoryCode: Code[20]; PostingDate: Date): Decimal
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        RatePct: Decimal;
    begin
        if SalespersonCode = '' then
            exit(0);
        if ItemCategoryCode <> '' then
            if FindRatePct(SalespersonCode, ItemCategoryCode, PostingDate, RatePct) then
                exit(RatePct);
        if FindRatePct(SalespersonCode, '', PostingDate, RatePct) then
            exit(RatePct);
        SalespersonPurchaser.SetLoadFields("Commission %");
        if not SalespersonPurchaser.Get(SalespersonCode) then
            exit(0);
        exit(SalespersonPurchaser."Commission %");
    end;

    // The key ends with "Starting Date": the range 0D..PostingDate includes the blank date (always) and FindLast
    // returns the most recent rate.
    local procedure FindRatePct(SalespersonCode: Code[20]; ItemCategoryCode: Code[20]; PostingDate: Date; var RatePct: Decimal): Boolean
    var
        CommissionRate: Record "Commission Rate_LDR";
    begin
        CommissionRate.SetRange("Salesperson Code", SalespersonCode);
        CommissionRate.SetRange("Item Category Code", ItemCategoryCode);
        CommissionRate.SetRange("Starting Date", 0D, PostingDate);
        CommissionRate.SetLoadFields("Commission %");
        if not CommissionRate.FindLast() then
            exit(false);
        RatePct := CommissionRate."Commission %";
        exit(true);
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
        CommissionSettlement: Record "Comm. Settlement_LDR";
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

    // TF0022 RF-4.1 / RF-4.2: exports the commission entries with the filters of the page to Excel with Excel
    // Buffer. Returns false when the filters return no entries (no file is created).
    procedure ExportToExcel(var CommissionEntryFilters: Record "Commission Entry_LDR"): Boolean
    var
        CommissionEntry: Record "Commission Entry_LDR";
        TempExcelBuffer: Record "Excel Buffer" temporary;
    begin
        CommissionEntry.CopyFilters(CommissionEntryFilters);
        if CommissionEntry.IsEmpty() then
            exit(false);

        AddExcelHeader(TempExcelBuffer, CommissionEntry);
        CommissionEntry.SetLoadFields(
            "Posting Date", "Document Type", "Document No.", "Salesperson Code", "Customer No.", "Base Amount (LCY)",
            "Commission %", "Commission Amount (LCY)", Liquidated, "Liquidation No.");
        CommissionEntry.FindSet();
        repeat
            AddExcelLine(TempExcelBuffer, CommissionEntry);
        until CommissionEntry.Next() = 0;

        TempExcelBuffer.CreateNewBook(CopyStr(CommissionEntry.TableCaption(), 1, 250));
        TempExcelBuffer.WriteSheet(CommissionEntry.TableCaption(), CompanyName(), UserId());
        TempExcelBuffer.CloseBook();
        TempExcelBuffer.SetFriendlyFilename(CommissionEntry.TableCaption());
        TempExcelBuffer.OpenExcel();
        exit(true);
    end;

    local procedure AddExcelHeader(var TempExcelBuffer: Record "Excel Buffer" temporary; CommissionEntry: Record "Commission Entry_LDR")
    begin
        TempExcelBuffer.NewRow();
        AddHeaderColumn(TempExcelBuffer, CommissionEntry.FieldCaption("Posting Date"));
        AddHeaderColumn(TempExcelBuffer, CommissionEntry.FieldCaption("Document Type"));
        AddHeaderColumn(TempExcelBuffer, CommissionEntry.FieldCaption("Document No."));
        AddHeaderColumn(TempExcelBuffer, CommissionEntry.FieldCaption("Salesperson Code"));
        AddHeaderColumn(TempExcelBuffer, SalespersonNameTxt);
        AddHeaderColumn(TempExcelBuffer, CommissionEntry.FieldCaption("Customer No."));
        AddHeaderColumn(TempExcelBuffer, CustomerNameTxt);
        AddHeaderColumn(TempExcelBuffer, CommissionEntry.FieldCaption("Base Amount (LCY)"));
        AddHeaderColumn(TempExcelBuffer, CommissionEntry.FieldCaption("Commission %"));
        AddHeaderColumn(TempExcelBuffer, CommissionEntry.FieldCaption("Commission Amount (LCY)"));
        AddHeaderColumn(TempExcelBuffer, CommissionEntry.FieldCaption(Liquidated));
        AddHeaderColumn(TempExcelBuffer, CommissionEntry.FieldCaption("Liquidation No."));
    end;

    local procedure AddHeaderColumn(var TempExcelBuffer: Record "Excel Buffer" temporary; Caption: Text)
    begin
        TempExcelBuffer.AddColumn(Caption, false, '', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    // P-8: the names are not stored in the entry; they are read from their tables when exporting.
    local procedure AddExcelLine(var TempExcelBuffer: Record "Excel Buffer" temporary; CommissionEntry: Record "Commission Entry_LDR")
    begin
        TempExcelBuffer.NewRow();
        TempExcelBuffer.AddColumn(CommissionEntry."Posting Date", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Date);
        TempExcelBuffer.AddColumn(Format(CommissionEntry."Document Type"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommissionEntry."Document No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommissionEntry."Salesperson Code", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GetSalespersonName(CommissionEntry."Salesperson Code"), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommissionEntry."Customer No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(GetCustomerName(CommissionEntry."Customer No."), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommissionEntry."Base Amount (LCY)", false, '', false, false, false, AmountFormatTxt, TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(CommissionEntry."Commission %", false, '', false, false, false, PctFormatTxt, TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(CommissionEntry."Commission Amount (LCY)", false, '', false, false, false, AmountFormatTxt, TempExcelBuffer."Cell Type"::Number);
        TempExcelBuffer.AddColumn(Format(CommissionEntry.Liquidated), false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
        TempExcelBuffer.AddColumn(CommissionEntry."Liquidation No.", false, '', false, false, false, '', TempExcelBuffer."Cell Type"::Text);
    end;

    local procedure GetSalespersonName(SalespersonCode: Code[20]): Text
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        SalespersonPurchaser.SetLoadFields(Name);
        if SalespersonPurchaser.Get(SalespersonCode) then
            exit(SalespersonPurchaser.Name);
    end;

    local procedure GetCustomerName(CustomerNo: Code[20]): Text
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields(Name);
        if Customer.Get(CustomerNo) then
            exit(Customer.Name);
    end;

    // TF0022 RF-5.1 / RF-5.3: exports the filtered entries with the XMLport to a CSV file and downloads it as
    // COMISIONES_AAAAMM.csv. Returns false when the filters return no entries (no file is created).
    procedure ExportPayrollFile(var CommissionEntryFilters: Record "Commission Entry_LDR"): Boolean
    var
        CommissionEntry: Record "Commission Entry_LDR";
        TempBlob: Codeunit "Temp Blob";
        CommissionPayrollExport: XmlPort "Commission Payroll Export_LDR";
        FileOutStream: OutStream;
        FileInStream: InStream;
        FileName: Text;
    begin
        CommissionEntry.CopyFilters(CommissionEntryFilters);
        if CommissionEntry.IsEmpty() then
            exit(false);

        TempBlob.CreateOutStream(FileOutStream, TextEncoding::UTF8);
        CommissionPayrollExport.SetTableView(CommissionEntry);
        CommissionPayrollExport.SetDestination(FileOutStream);
        CommissionPayrollExport.Export();

        FileName := StrSubstNo(PayrollFileNameTxt, Format(CommissionPayrollExport.GetLatestPostingDate(), 0, '<Year4><Month,2>'));
        TempBlob.CreateInStream(FileInStream, TextEncoding::UTF8);
        DownloadFromStream(FileInStream, '', '', '', FileName);
        exit(true);
    end;

    // TF0023 RF-3.1: true when the salesperson has commission entries not settled up to the date. Only reads.
    procedure HasPendingCommissions(SalespersonCode: Code[20]; UpToDate: Date): Boolean
    var
        CommissionEntry: Record "Commission Entry_LDR";
    begin
        CommissionEntry.SetCurrentKey("Salesperson Code", Liquidated, "Posting Date");
        CommissionEntry.SetRange("Salesperson Code", SalespersonCode);
        CommissionEntry.SetRange(Liquidated, false);
        CommissionEntry.SetRange("Posting Date", 0D, UpToDate);
        exit(not CommissionEntry.IsEmpty());
    end;

    var
        PayrollFileNameTxt: Label 'COMISIONES_%1.csv', Locked = true;
        SalespersonNameTxt: Label 'Salesperson Name', Comment = 'ESP="Nombre vendedor"';
        CustomerNameTxt: Label 'Customer Name', Comment = 'ESP="Nombre cliente"';
        AmountFormatTxt: Label '#,##0.00', Locked = true;
        PctFormatTxt: Label '0.00###', Locked = true;
        InvoicePostedErr: Label 'Purchase invoice %1 of settlement %2 has already been posted. The settlement cannot be undone.', Comment = 'ESP="La factura de compra %1 de la liquidación %2 ya está registrada. No se puede deshacer la liquidación." %1 = purchase invoice no., %2 = settlement no.';
}

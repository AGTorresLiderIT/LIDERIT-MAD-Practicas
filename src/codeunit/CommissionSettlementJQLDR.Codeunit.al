codeunit 50007 "Commission Settlement JQ_LDR"
{
    // TF0023 RF-3.1 to RF-3.5: automatic commission settlement run from the job queue.
    // No Message, Confirm or Dialog: "Run once (foreground)" runs with GuiAllowed true, so GuiAllowed is not enough.
    // P-4: Codeunit.Run with a return value needs no open write transaction, so there is a Commit before the
    // first salesperson and after the log line of each one. The log line is inserted outside the Run, so it is
    // kept when the settlement of the salesperson fails.
    // P-3: no control of a second run in the same month: only entries not settled are selected, so a second run
    // or a retry of the job queue only finds what is still pending.
    TableNo = "Job Queue Entry";
    Permissions = tabledata "Commission Process Log_LDR" = ri;

    trigger OnRun()
    var
        CreatePurchaseInvoice: Boolean;
        DaysBefore: Integer;
    begin
        // RF-3.4: parameters and setup are checked before writing anything. An error here leaves the job queue
        // entry in Error with the message and nothing is settled.
        ReadParameters(Rec."Parameter String", CreatePurchaseInvoice, DaysBefore);
        CheckSetup(CreatePurchaseInvoice);

        // RF-3.1 / P-1: Today and not WorkDate: the work date is a setting of the user session and does not move.
        UpToDate := CalcDate('<-CM-1D>', Today()) - DaysBefore;
        CreateInvoice := CreatePurchaseInvoice;
        RunID := CreateGuid();
        StartDateTime := CurrentDateTime();

        Commit();
        SettlePendingSalespersons();
    end;

    local procedure SettlePendingSalespersons()
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        CommissionMgt: Codeunit "Commission Mgt._LDR";
        SalespersonCodes: List of [Code[20]];
        SalespersonCode: Code[20];
    begin
        // The codes are read first so that no cursor stays open across the Commit of each salesperson.
        SalespersonPurchaser.SetLoadFields(Code);
        if SalespersonPurchaser.FindSet() then
            repeat
                if CommissionMgt.HasPendingCommissions(SalespersonPurchaser.Code, UpToDate) then
                    SalespersonCodes.Add(SalespersonPurchaser.Code);
            until SalespersonPurchaser.Next() = 0;

        if SalespersonCodes.Count() = 0 then begin
            InsertLog('', "Commission Process Status_LDR"::Warning, '', StrSubstNo(NoPendingCommissionsMsg, UpToDate));
            Commit();
            exit;
        end;

        foreach SalespersonCode in SalespersonCodes do begin
            SettleSalesperson(SalespersonCode);
            Commit();
        end;
    end;

    // RF-1.1: the same codeunit as the manual report of TF0021. RF-3.2: an error only affects this salesperson.
    local procedure SettleSalesperson(SalespersonCode: Code[20])
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        SettleSalespersonCommission: Codeunit "Salesp. Comm. Settlement_LDR";
        SettlementNo: Code[20];
        WarningText: Text;
    begin
        ClearLastError();
        Clear(SettleSalespersonCommission);
        SalespersonPurchaser.Get(SalespersonCode);
        SettleSalespersonCommission.SetParameters(UpToDate, CreateInvoice);
        if not SettleSalespersonCommission.Run(SalespersonPurchaser) then begin
            InsertLog(SalespersonCode, "Commission Process Status_LDR"::Error, '', GetLastErrorText());
            exit;
        end;

        SettlementNo := SettleSalespersonCommission.GetSettlementNo();
        WarningText := SettleSalespersonCommission.GetWarningText();
        case true of
            // P1: another process (the manual report) settled the salesperson in the meantime.
            SettlementNo = '':
                InsertLog(SalespersonCode, "Commission Process Status_LDR"::Warning, '', StrSubstNo(NoPendingCommissionsMsg, UpToDate));
            // RF-3.3: settled without invoice (no vendor, vendor not valid or total <= 0), as in TF0021.
            WarningText <> '':
                InsertLog(SalespersonCode, "Commission Process Status_LDR"::Warning, SettlementNo, WarningText);
            else
                InsertLog(SalespersonCode, "Commission Process Status_LDR"::Success, SettlementNo, '');
        end;
    end;

    local procedure InsertLog(SalespersonCode: Code[20]; Status: Enum "Commission Process Status_LDR"; SettlementNo: Code[20]; LogMessage: Text)
    var
        CommissionProcessLog: Record "Commission Process Log_LDR";
    begin
        CommissionProcessLog.Init();
        CommissionProcessLog."Entry No." := 0;
        CommissionProcessLog."Run ID" := RunID;
        CommissionProcessLog."Start Date-Time" := StartDateTime;
        CommissionProcessLog."End Date-Time" := CurrentDateTime();
        CommissionProcessLog."Salesperson Code" := SalespersonCode;
        CommissionProcessLog.Status := Status;
        CommissionProcessLog."Settlement No." := SettlementNo;
        CommissionProcessLog.Message := CopyStr(LogMessage, 1, MaxStrLen(CommissionProcessLog.Message));
        CommissionProcessLog."User ID" := CopyStr(UserId(), 1, MaxStrLen(CommissionProcessLog."User ID"));
        CommissionProcessLog.Insert();
    end;

    // P-5: KEY=VALUE pairs separated by ";", keys FACTURA (SI/NO) and DIAS (integer >= 0), not case sensitive.
    // Empty means FACTURA=SI;DIAS=0. An unknown key, a wrong value or a repeated key is an error.
    local procedure ReadParameters(ParameterString: Text; var CreatePurchaseInvoice: Boolean; var DaysBefore: Integer)
    var
        Pair: Text;
        ParameterKey: Text;
        ParameterValue: Text;
        InvoiceRead: Boolean;
        DaysRead: Boolean;
        EqualPos: Integer;
    begin
        CreatePurchaseInvoice := true;
        DaysBefore := 0;
        if DelChr(ParameterString, '<>', ' ') = '' then
            exit;

        foreach Pair in ParameterString.Split(';') do begin
            EqualPos := StrPos(Pair, '=');
            if EqualPos = 0 then
                Error(InvalidParameterErr, ParameterString);
            ParameterKey := UpperCase(DelChr(CopyStr(Pair, 1, EqualPos - 1), '<>', ' '));
            ParameterValue := UpperCase(DelChr(CopyStr(Pair, EqualPos + 1), '<>', ' '));
            case ParameterKey of
                'FACTURA':
                    begin
                        if InvoiceRead or not (ParameterValue in ['SI', 'NO']) then
                            Error(InvalidParameterErr, ParameterString);
                        CreatePurchaseInvoice := ParameterValue = 'SI';
                        InvoiceRead := true;
                    end;
                'DIAS':
                    begin
                        if DaysRead or not Evaluate(DaysBefore, ParameterValue) or (DaysBefore < 0) then
                            Error(InvalidParameterErr, ParameterString);
                        DaysRead := true;
                    end;
                else
                    Error(InvalidParameterErr, ParameterString);
            end;
        end;
    end;

    // P1: the setup is checked once at the start. Otherwise the codeunit of TF0021 would fail for every
    // salesperson and the log would have one error line per salesperson.
    // The account must also be a posting account with direct posting: otherwise the invoice line fails for every
    // salesperson with a vendor (found in the tests: "Direct Posting must be equal to Yes").
    local procedure CheckSetup(CreatePurchaseInvoice: Boolean)
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        GLAccount: Record "G/L Account";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Commission Settlement Nos._LDR");
        if not CreatePurchaseInvoice then
            exit;
        SalesReceivablesSetup.TestField("Commission Account_LDR");
        GLAccount.Get(SalesReceivablesSetup."Commission Account_LDR");
        GLAccount.TestField("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.TestField("Direct Posting", true);
    end;

    var
        RunID: Guid;
        StartDateTime: DateTime;
        UpToDate: Date;
        CreateInvoice: Boolean;
        InvalidParameterErr: Label 'The parameter string ''%1'' is not valid. Use FACTURA=SI|NO;DIAS=<number of days>.', Comment = 'ESP="El parámetro ''%1'' no es válido. Use FACTURA=SI|NO;DIAS=<nº de días>." %1 = parameter string of the job queue entry';
        NoPendingCommissionsMsg: Label 'No pending commissions up to %1.', Comment = 'ESP="Sin comisiones pendientes hasta el %1." %1 = up to date';
}

codeunit 50005 "Commission Rate Import_LDR"
{
    // TF0022 RF-3.1 to RF-3.3: imports commission rates from an Excel file with Excel Buffer. An XMLport cannot
    // read an .xlsx file (it only reads XML or delimited/fixed text), so Excel Buffer is used.
    // P-4: each row is processed on its own; wrong rows go to a temporary error table and the import goes on.
    Permissions = tabledata "Commission Rate_LDR" = rim;

    procedure ImportFromExcel()
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        TempCommissionImportError: Record "Commission Import Error_LDR" temporary;
        CommissionImportErrors: Page "Commission Import Errors_LDR";
        FileInStream: InStream;
        FileName: Text;
        SheetName: Text;
        OpenError: Text;
        ImportedCount: Integer;
        ModifiedCount: Integer;
    begin
        if not UploadIntoStream(SelectFileTxt, '', ExcelFileFilterTxt, FileName, FileInStream) then
            exit;
        SheetName := TempExcelBuffer.SelectSheetsNameStream(FileInStream);
        if SheetName = '' then
            exit;
        OpenError := TempExcelBuffer.OpenBookStream(FileInStream, SheetName);
        if OpenError <> '' then
            Error(OpenError);
        TempExcelBuffer.ReadSheet();

        // Row 1 holds the headers.
        TempExcelBuffer.SetFilter("Row No.", '>1');
        if TempExcelBuffer.IsEmpty() then
            Error(NoDataErr);

        ProcessRows(TempExcelBuffer, TempCommissionImportError, ImportedCount, ModifiedCount);

        Message(ImportResultMsg, ImportedCount, ModifiedCount, TempCommissionImportError.Count());
        if not TempCommissionImportError.IsEmpty() then begin
            CommissionImportErrors.SetErrors(TempCommissionImportError);
            CommissionImportErrors.Run();
        end;
    end;

    // The cells come ordered by "Row No." and "Column No." (primary key). The cells of each row are grouped and
    // the row is processed when the next row starts. Empty cells are not in the buffer, so a completely empty
    // row never appears and is skipped.
    local procedure ProcessRows(var TempExcelBuffer: Record "Excel Buffer" temporary; var TempCommissionImportError: Record "Commission Import Error_LDR" temporary; var ImportedCount: Integer; var ModifiedCount: Integer)
    var
        CellValues: array[4] of Text;
        CellFormats: array[4] of Text;
        CurrentRowNo: Integer;
    begin
        TempExcelBuffer.FindSet();
        CurrentRowNo := TempExcelBuffer."Row No.";
        repeat
            if TempExcelBuffer."Row No." <> CurrentRowNo then begin
                ProcessRow(CurrentRowNo, CellValues, CellFormats, TempCommissionImportError, ImportedCount, ModifiedCount);
                Clear(CellValues);
                Clear(CellFormats);
                CurrentRowNo := TempExcelBuffer."Row No.";
            end;
            if TempExcelBuffer."Column No." in [1 .. 4] then begin
                CellValues[TempExcelBuffer."Column No."] := DelChr(TempExcelBuffer."Cell Value as Text", '<>', ' ');
                CellFormats[TempExcelBuffer."Column No."] := TempExcelBuffer.NumberFormat;
            end;
        until TempExcelBuffer.Next() = 0;
        ProcessRow(CurrentRowNo, CellValues, CellFormats, TempCommissionImportError, ImportedCount, ModifiedCount);
    end;

    local procedure ProcessRow(RowNo: Integer; CellValues: array[4] of Text; CellFormats: array[4] of Text; var TempCommissionImportError: Record "Commission Import Error_LDR" temporary; var ImportedCount: Integer; var ModifiedCount: Integer)
    var
        CommissionRate: Record "Commission Rate_LDR";
        SalespersonCode: Code[20];
        ItemCategoryCode: Code[20];
        StartingDate: Date;
        CommissionPct: Decimal;
        Reason: Text;
    begin
        // Only columns beyond D: nothing to import.
        if (CellValues[1] = '') and (CellValues[2] = '') and (CellValues[3] = '') and (CellValues[4] = '') then
            exit;

        if not ValidateRow(CellValues, CellFormats, SalespersonCode, ItemCategoryCode, CommissionPct, StartingDate, Reason) then begin
            AddError(TempCommissionImportError, RowNo, CellValues, Reason);
            exit;
        end;

        // P-3: a repeated key in the same file is modified again, so the last row wins.
        if CommissionRate.Get(SalespersonCode, ItemCategoryCode, StartingDate) then begin
            CommissionRate."Commission %" := CommissionPct;
            CommissionRate.Modify(true);
            ModifiedCount += 1;
        end else begin
            CommissionRate.Init();
            CommissionRate."Salesperson Code" := SalespersonCode;
            CommissionRate."Item Category Code" := ItemCategoryCode;
            CommissionRate."Starting Date" := StartingDate;
            CommissionRate."Commission %" := CommissionPct;
            CommissionRate.Insert(true);
            ImportedCount += 1;
        end;
    end;

    // RF-3.2: every check is done here and returns the reason, so a wrong row never stops the import.
    local procedure ValidateRow(CellValues: array[4] of Text; CellFormats: array[4] of Text; var SalespersonCode: Code[20]; var ItemCategoryCode: Code[20]; var CommissionPct: Decimal; var StartingDate: Date; var Reason: Text): Boolean
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        ItemCategory: Record "Item Category";
    begin
        // Column A: salesperson, mandatory, in capital letters (P1) and existing.
        if CellValues[1] = '' then
            exit(SetReason(Reason, SalespersonMissingErr));
        if (StrLen(CellValues[1]) > MaxStrLen(SalespersonCode)) or (CellValues[1] <> UpperCase(CellValues[1])) then
            exit(SetReason(Reason, StrSubstNo(SalespersonFormatErr, CellValues[1])));
        SalespersonCode := CopyStr(CellValues[1], 1, MaxStrLen(SalespersonCode));
        if not SalespersonPurchaser.Get(SalespersonCode) then
            exit(SetReason(Reason, StrSubstNo(SalespersonNotFoundErr, SalespersonCode)));

        // Column B: item category, optional; if it comes, it must exist.
        if CellValues[2] <> '' then begin
            if StrLen(CellValues[2]) > MaxStrLen(ItemCategoryCode) then
                exit(SetReason(Reason, StrSubstNo(ItemCategoryNotFoundErr, CellValues[2])));
            ItemCategoryCode := CopyStr(CellValues[2], 1, MaxStrLen(ItemCategoryCode));
            if not ItemCategory.Get(ItemCategoryCode) then
                exit(SetReason(Reason, StrSubstNo(ItemCategoryNotFoundErr, CellValues[2])));
        end;

        // Column C: %, mandatory, numeric between 0 and 100. A cell with percentage format comes as 0.08 for
        // 8 %: Excel Buffer keeps the cell format in NumberFormat, so the value is multiplied by 100 (P1).
        if CellValues[3] = '' then
            exit(SetReason(Reason, PctMissingErr));
        if not Evaluate(CommissionPct, CellValues[3]) then
            exit(SetReason(Reason, StrSubstNo(PctNotNumericErr, CellValues[3])));
        if StrPos(CellFormats[3], '%') <> 0 then
            CommissionPct := CommissionPct * 100;
        if (CommissionPct < 0) or (CommissionPct > 100) then
            exit(SetReason(Reason, StrSubstNo(PctOutOfRangeErr, CommissionPct)));

        // Column D: starting date, optional. Date cells come as a date text; a number is taken as an Excel
        // serial date (P-3).
        if CellValues[4] <> '' then
            if not EvaluateDate(CellValues[4], StartingDate) then
                exit(SetReason(Reason, StrSubstNo(DateNotValidErr, CellValues[4])));

        exit(true);
    end;

    local procedure EvaluateDate(CellValue: Text; var StartingDate: Date): Boolean
    var
        TempExcelBuffer: Record "Excel Buffer" temporary;
        SerialDate: Decimal;
    begin
        if Evaluate(StartingDate, CellValue) then
            exit(true);
        if not Evaluate(SerialDate, CellValue) then
            exit(false);
        if (SerialDate < 1) or (SerialDate <> Round(SerialDate, 1)) then
            exit(false);
        StartingDate := DT2Date(TempExcelBuffer.ConvertDateTimeDecimalToDateTime(SerialDate));
        exit(true);
    end;

    local procedure SetReason(var Reason: Text; NewReason: Text): Boolean
    begin
        Reason := NewReason;
        exit(false);
    end;

    local procedure AddError(var TempCommissionImportError: Record "Commission Import Error_LDR" temporary; RowNo: Integer; CellValues: array[4] of Text; Reason: Text)
    begin
        TempCommissionImportError.Init();
        TempCommissionImportError."Row No." := RowNo;
        TempCommissionImportError."Row Text" := CopyStr(
            StrSubstNo(RowTextTxt, CellValues[1], CellValues[2], CellValues[3], CellValues[4]), 1, MaxStrLen(TempCommissionImportError."Row Text"));
        TempCommissionImportError.Reason := CopyStr(Reason, 1, MaxStrLen(TempCommissionImportError.Reason));
        TempCommissionImportError.Insert();
    end;

    var
        SelectFileTxt: Label 'Select the Excel file with the commission rates', Comment = 'ESP="Seleccione el fichero Excel con las tarifas de comisión"';
        ExcelFileFilterTxt: Label 'Excel files (*.xlsx)|*.xlsx', Comment = 'ESP="Ficheros Excel (*.xlsx)|*.xlsx"';
        NoDataErr: Label 'The sheet has no data after the header row. Nothing has been imported.', Comment = 'ESP="La hoja no tiene datos después de la fila de cabeceras. No se ha importado nada."';
        ImportResultMsg: Label 'Import finished. Rows imported: %1. Modified: %2. With error: %3.', Comment = 'ESP="Importación terminada. Filas importadas: %1. Modificadas: %2. Con error: %3." %1 = rows inserted, %2 = rows modified, %3 = rows with error';
        SalespersonMissingErr: Label 'The salesperson is missing.', Comment = 'ESP="Falta el vendedor."';
        SalespersonFormatErr: Label 'The salesperson %1 must be in capital letters and have 20 characters at most.', Comment = 'ESP="El vendedor %1 debe estar en mayúsculas y tener como máximo 20 caracteres." %1 = salesperson code';
        SalespersonNotFoundErr: Label 'The salesperson %1 does not exist.', Comment = 'ESP="El vendedor %1 no existe." %1 = salesperson code';
        ItemCategoryNotFoundErr: Label 'The item category %1 does not exist.', Comment = 'ESP="La categoría de producto %1 no existe." %1 = item category code';
        PctMissingErr: Label 'The commission percentage is missing.', Comment = 'ESP="Falta el porcentaje de comisión."';
        PctNotNumericErr: Label 'The commission percentage %1 is not a number.', Comment = 'ESP="El porcentaje de comisión %1 no es un número." %1 = value of the cell';
        PctOutOfRangeErr: Label 'The percentage must be between 0 and 100 (value: %1).', Comment = 'ESP="El porcentaje debe estar entre 0 y 100 (valor: %1)." %1 = percentage';
        DateNotValidErr: Label 'The starting date %1 is not a valid date.', Comment = 'ESP="La fecha de inicio %1 no es una fecha válida." %1 = value of the cell';
        RowTextTxt: Label '%1 | %2 | %3 | %4', Locked = true;
}

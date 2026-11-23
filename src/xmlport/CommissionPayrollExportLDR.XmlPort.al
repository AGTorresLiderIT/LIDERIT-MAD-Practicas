xmlport 50000 "Commission Payroll Export_LDR"
{
    // TF0022 RF-5.1 / RF-5.2: fixed-format CSV for the payroll program. Variable text with ";" as separator,
    // no text delimiter ('<None>', as in the standard XMLport 1660 "Import Payroll") and UTF-8.
    // There is no property to write the field names, so the first line comes from a "Header" table element on
    // Integer with one record and fixed texts (P-5). The entries go after it at the same level.
    Caption = 'Commission Payroll Export', Comment = 'ESP="Exportación de comisiones para nóminas"';
    Direction = Export;
    FieldDelimiter = '<None>';
    FieldSeparator = ';';
    Format = VariableText;
    TextEncoding = UTF8;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(Header; Integer)
            {
                SourceTableView = where(Number = const(1));
                XmlName = 'Header';
                textelement(SalespersonCodeHeader) { }
                textelement(SalespersonNameHeader) { }
                textelement(PostingDateHeader) { }
                textelement(DocumentNoHeader) { }
                textelement(CommissionAmountHeader) { }

                trigger OnAfterGetRecord()
                begin
                    SalespersonCodeHeader := 'SalespersonCode';
                    SalespersonNameHeader := 'SalespersonName';
                    PostingDateHeader := 'PostingDate';
                    DocumentNoHeader := 'DocumentNo';
                    CommissionAmountHeader := 'CommissionAmount';
                end;
            }
            tableelement(CommissionEntry; "Commission Entry_LDR")
            {
                XmlName = 'CommissionEntry';
                fieldelement(SalespersonCode; CommissionEntry."Salesperson Code") { }
                textelement(SalespersonName) { }
                textelement(PostingDate) { }
                fieldelement(DocumentNo; CommissionEntry."Document No.") { }
                textelement(CommissionAmount) { }

                trigger OnAfterGetRecord()
                begin
                    // P-6: a ";" inside the name would break the columns, so it is replaced by ",".
                    SalespersonName := ConvertStr(GetSalespersonName(CommissionEntry."Salesperson Code"), ';', ',');
                    PostingDate := Format(CommissionEntry."Posting Date", 0, '<Year4><Month,2><Day,2>');
                    // Two decimals with a point, as the standard does for SEPA and SII amounts.
                    CommissionAmount := Format(CommissionEntry."Commission Amount (LCY)", 0, '<Precision,2:2><Standard Format,9>');
                    if CommissionEntry."Posting Date" > LatestPostingDate then
                        LatestPostingDate := CommissionEntry."Posting Date";
                end;
            }
        }
    }

    // RF-5.3 / P-6: the file name uses the most recent posting date of the exported entries.
    procedure GetLatestPostingDate(): Date
    begin
        exit(LatestPostingDate);
    end;

    local procedure GetSalespersonName(SalespCode: Code[20]): Text
    var
        SalespersonPurchaser: Record "Salesperson/Purchaser";
    begin
        SalespersonPurchaser.SetLoadFields(Name);
        if SalespersonPurchaser.Get(SalespCode) then
            exit(SalespersonPurchaser.Name);
    end;

    var
        LatestPostingDate: Date;
}

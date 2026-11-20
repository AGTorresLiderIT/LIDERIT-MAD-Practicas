table 50002 "Comm. Settlement_LDR"
{
    Caption = 'Commission Settlement', Comment = 'ESP="Liquidación de comisiones"';
    DataClassification = CustomerContent;
    DrillDownPageId = "Commission Settlements_LDR";
    LookupPageId = "Commission Settlements_LDR";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.', Comment = 'ESP="Nº"';
            ToolTip = 'Specifies the number of the commission settlement.', Comment = 'ESP="Especifica el número de la liquidación de comisiones."';
        }
        field(2; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code', Comment = 'ESP="Cód. vendedor"';
            TableRelation = "Salesperson/Purchaser";
            ToolTip = 'Specifies the salesperson whose commissions are settled.', Comment = 'ESP="Especifica el vendedor cuyas comisiones se liquidan."';
        }
        field(3; "Settlement Date"; Date)
        {
            Caption = 'Settlement Date', Comment = 'ESP="Fecha liquidación"';
            ToolTip = 'Specifies the date on which the settlement was created.', Comment = 'ESP="Especifica la fecha en que se creó la liquidación."';
        }
        field(4; "Up To Date"; Date)
        {
            Caption = 'Up To Date', Comment = 'ESP="Fecha hasta"';
            ToolTip = 'Specifies the posting date up to which the commission entries were settled.', Comment = 'ESP="Especifica la fecha de registro hasta la que se liquidaron los movimientos de comisión."';
        }
        field(5; "Total Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Commission Entry_LDR"."Commission Amount (LCY)" where("Liquidation No." = field("No.")));
            Caption = 'Total Amount (LCY)', Comment = 'ESP="Importe total (DL)"';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the sum of the commission amounts of the entries included in the settlement.', Comment = 'ESP="Especifica la suma de los importes de comisión de los movimientos incluidos en la liquidación."';
        }
        field(6; "No. of Entries"; Integer)
        {
            CalcFormula = count("Commission Entry_LDR" where("Liquidation No." = field("No.")));
            Caption = 'No. of Entries', Comment = 'ESP="Nº movimientos"';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the number of commission entries included in the settlement.', Comment = 'ESP="Especifica el número de movimientos de comisión incluidos en la liquidación."';
        }
        field(7; "Purchase Invoice No."; Code[20])
        {
            Caption = 'Purchase Invoice No.', Comment = 'ESP="Nº factura compra"';
            ToolTip = 'Specifies the draft purchase invoice created for the settlement, if any.', Comment = 'ESP="Especifica la factura de compra borrador creada para la liquidación, si se creó."';
        }
        field(8; "No. Series"; Code[20])
        {
            Caption = 'No. Series', Comment = 'ESP="Nº serie"';
            Editable = false;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series from which the settlement number was assigned.', Comment = 'ESP="Especifica el nº de serie del que se asignó el número de la liquidación."';
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if "No." <> '' then
            exit;

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.TestField("Commission Settlement Nos._LDR");
        "No. Series" := SalesReceivablesSetup."Commission Settlement Nos._LDR";
        "No." := NoSeries.GetNextNo("No. Series", WorkDate());
    end;
}

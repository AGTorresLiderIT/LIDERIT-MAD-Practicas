tableextension 50000 "Salesperson/Purchaser_LDR" extends "Salesperson/Purchaser"
{
    fields
    {
        field(50000; "Pending Commission (LCY)_LDR"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = sum("Commission Entry_LDR"."Commission Amount (LCY)" where("Salesperson Code" = field(Code), Liquidated = const(false)));
            Caption = 'Pending Commission (LCY)', Comment = 'ESP="Comisión pendiente (DL)"';
            Editable = false;
            FieldClass = FlowField;
            ToolTip = 'Specifies the sum of the commissions of the salesperson that are not liquidated yet.', Comment = 'ESP="Especifica la suma de las comisiones del vendedor que aún no se han liquidado."';
        }
        field(50001; "Vendor No._LDR"; Code[20])
        {
            Caption = 'Vendor No.', Comment = 'ESP="Nº proveedor"';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ToolTip = 'Specifies the vendor to which the commission of the salesperson is invoiced.', Comment = 'ESP="Especifica el proveedor al que se factura la comisión del vendedor."';
        }
    }
}

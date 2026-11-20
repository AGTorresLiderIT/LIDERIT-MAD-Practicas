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
    }
}

enum 50000 "Commission Document Type_LDR"
{
    Caption = 'Commission Document Type', Comment = 'ESP="Tipo documento comisión"';
    Extensible = true;

    value(0; Invoice)
    {
        Caption = 'Invoice', Comment = 'ESP="Factura"';
    }
    value(1; "Credit Memo")
    {
        Caption = 'Credit Memo', Comment = 'ESP="Abono"';
    }
}

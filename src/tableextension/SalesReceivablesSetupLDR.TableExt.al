tableextension 50002 "Sales & Receivables Setup_LDR" extends "Sales & Receivables Setup"
{
    fields
    {
        field(50000; "Commission Settlement Nos._LDR"; Code[20])
        {
            Caption = 'Commission Settlement Nos.', Comment = 'ESP="Nº serie liquidación comisiones"';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            ToolTip = 'Specifies the number series used to number the commission settlements.', Comment = 'ESP="Especifica el nº de serie que se usa para numerar las liquidaciones de comisiones."';
        }
        field(50001; "Commission Account_LDR"; Code[20])
        {
            Caption = 'Commission Account', Comment = 'ESP="Cuenta comisiones"';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
            ToolTip = 'Specifies the G/L account used in the purchase invoice line created when a commission settlement is invoiced.', Comment = 'ESP="Especifica la cuenta contable que se usa en la línea de la factura de compra que se crea al facturar una liquidación de comisiones."';
        }
    }
}

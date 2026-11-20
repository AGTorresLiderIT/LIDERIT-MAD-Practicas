table 50001 "Commission Entry_LDR"
{
    Caption = 'Commission Entry', Comment = 'ESP="Movimiento de comisión"';
    DataClassification = CustomerContent;
    DrillDownPageId = "Commission Entries_LDR";
    LookupPageId = "Commission Entries_LDR";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.', Comment = 'ESP="Nº mov."';
            ToolTip = 'Specifies the number of the entry.', Comment = 'ESP="Especifica el número del movimiento."';
        }
        field(2; "Posting Date"; Date)
        {
            Caption = 'Posting Date', Comment = 'ESP="Fecha registro"';
            ToolTip = 'Specifies the posting date of the invoice or credit memo.', Comment = 'ESP="Especifica la fecha de registro de la factura o el abono."';
        }
        field(3; "Document Type"; Enum "Commission Document Type_LDR")
        {
            Caption = 'Document Type', Comment = 'ESP="Tipo documento"';
            ToolTip = 'Specifies whether the entry comes from an invoice or a credit memo.', Comment = 'ESP="Especifica si el movimiento procede de una factura o de un abono."';
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.', Comment = 'ESP="Nº documento"';
            ToolTip = 'Specifies the number of the posted invoice or credit memo.', Comment = 'ESP="Especifica el número de la factura o el abono registrado."';
        }
        field(5; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.', Comment = 'ESP="Nº línea documento"';
            ToolTip = 'Specifies the line number of the posted document.', Comment = 'ESP="Especifica el número de línea del documento registrado."';
        }
        field(6; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code', Comment = 'ESP="Cód. vendedor"';
            TableRelation = "Salesperson/Purchaser";
            ToolTip = 'Specifies the salesperson of the posted document.', Comment = 'ESP="Especifica el vendedor del documento registrado."';
        }
        field(7; "Customer No."; Code[20])
        {
            Caption = 'Customer No.', Comment = 'ESP="Nº cliente"';
            TableRelation = Customer;
            ToolTip = 'Specifies the sell-to customer of the posted document.', Comment = 'ESP="Especifica el cliente (venta a) del documento registrado."';
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.', Comment = 'ESP="Nº producto"';
            TableRelation = Item;
            ToolTip = 'Specifies the item of the posted line.', Comment = 'ESP="Especifica el producto de la línea registrada."';
        }
        field(9; "Base Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Base Amount (LCY)', Comment = 'ESP="Importe base (DL)"';
            ToolTip = 'Specifies the line amount excluding VAT in local currency. It is negative for credit memos.', Comment = 'ESP="Especifica el importe de la línea sin IVA en divisa local. Es negativo en los abonos."';
        }
        field(10; "Commission %"; Decimal)
        {
            Caption = 'Commission %', Comment = 'ESP="% comisión"';
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the commission percentage of the salesperson when the document was posted.', Comment = 'ESP="Especifica el porcentaje de comisión del vendedor en el momento del registro."';
        }
        field(11; "Commission Amount (LCY)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Commission Amount (LCY)', Comment = 'ESP="Importe comisión (DL)"';
            ToolTip = 'Specifies the commission amount in local currency. It is negative for credit memos.', Comment = 'ESP="Especifica el importe de la comisión en divisa local. Es negativo en los abonos."';
        }
        field(12; Liquidated; Boolean)
        {
            Caption = 'Liquidated', Comment = 'ESP="Liquidado"';
            ToolTip = 'Specifies whether the commission has been liquidated.', Comment = 'ESP="Especifica si la comisión se ha liquidado."';
        }
        field(13; "Liquidation No."; Code[20])
        {
            Caption = 'Liquidation No.', Comment = 'ESP="Nº liquidación"';
            ToolTip = 'Specifies the liquidation that includes the commission.', Comment = 'ESP="Especifica la liquidación que incluye la comisión."';
        }
        field(14; "User ID"; Code[50])
        {
            Caption = 'User ID', Comment = 'ESP="Id. usuario"';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user who posted the document.', Comment = 'ESP="Especifica el usuario que registró el documento."';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SalespersonLiquidated; "Salesperson Code", Liquidated, "Posting Date")
        {
            SumIndexFields = "Commission Amount (LCY)";
        }
        key(DocumentNo; "Document No.", "Posting Date")
        {
        }
    }
}

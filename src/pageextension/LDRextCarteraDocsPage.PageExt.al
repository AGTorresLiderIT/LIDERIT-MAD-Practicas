pageextension 50000 extCarteraDocsPage extends "Payables Cartera Docs"
{
    layout
    {
        addafter("Cust./Vendor Bank Acc. Code")
        {
            field("IBAN Proveedor"; Rec."IBAN Proveedor")
            {
                ApplicationArea = All;
                Caption = 'IBAN';
                Editable = false;
            }
        }
    }
}

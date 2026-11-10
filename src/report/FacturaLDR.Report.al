report 54000 "Factura_LDR"
{
    Caption = 'Factura';
    ApplicationArea = All;
    RDLCLayout = './src/report/layout/FacturaEjercicio.rdlc';
    DefaultLayout = RDLC;
    EnableExternalImages = true;

    dataset
    {
        dataitem("Sales Invoice Header"; "Sales Invoice Header")
        {
            column(Bill_to_Address; "Bill-to Address") { }
            column(Ship_to_Address; "Ship-to Address") { }
            column(VAT_Registration_No_; "VAT Registration No.") { }
            column(Posting_Date; "Posting Date") { }
            column(Shipping_Agent_Code; "Shipping Agent Code") { }
            column(No_; "No.") { }
        }
        dataitem("Company Information"; "Company Information")
        {
            column(Name; Name) { }
            column(Address; Address) { }
            column(E_Mail; "E-Mail") { }
            column(imagenURL; imagenURL) { }

            trigger OnAfterGetRecord()
            var
            begin
                imagenURL := 'https://thesimpsonsapi.com/api/characters/1.webp';
            end;
        }
        dataitem("Sales Invoice Line"; "Sales Invoice Line")
        {
            column(Description; Description) { }
            column(Quantity; Quantity) { }
            column(Unit_Price; "Unit Price") { }
            column(Amount; Amount) { }
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
    var
        imagenURL: Text;
}

report 50200 RepInformesVenta
{
    ApplicationArea = All;
    Caption = 'Informe de ventas agrupado por cliente';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = 'src\report\layout\ReportInformesVenta.rdl';
    dataset
    {

        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = where("Document Type" = const(Order));

            column(OrderNo; "No.") { }
            column(NoDocExt; "External Document No.") { }
            column(Country; "VAT Country/Region Code") { }
            column(Population; "Ship-to City") { }
            column(PostingDate; "Posting Date") { }
            column(CurrencyCode; "Currency Code") { }
            column(Currency_Factor; "Currency Factor") { }
            column(Amount; "Amount Including VAT") { }
            column(CompanyName; Companyinfo.Name) { }
            column(Contact_Person; CompanyInfo."Contact Person") { }
            column(Created_DateTime; today) { }
            column(Picture; CompanyInfo.picture) { }
            column(CustomerNo; "Sell-to Customer No.") { }
            column(CustomerName; "Sell-to Customer Name") { }

            dataitem(SalesLine; "Sales Line")
            {
                DataItemLink = "Document No." = field("No.");

                column(Line_Amount; "Line Amount") { }
                column(totallinesamount; totallinesamount) { }
                trigger OnAfterGetRecord()
                begin
                    totallinesamount += SalesLine."Line Amount";
                end;
            }

            //dataitem(Customer; Customer)
            //{
            //    DataItemLink = "No." = field("Sell-to Customer No.");
            //    column(CustomerNo; "No.") { }
            //    column(CustomerName; "Name") { }
            //}

            trigger OnAfterGetRecord()
            begin
                CompanyInfo.CalcFields(Picture);
            end;
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
    trigger OnPreReport()
    begin
        CompanyInfo.Get();
    end;

    var
        CompanyInfo: Record "Company Information";
        totallinesamount: Decimal;
}


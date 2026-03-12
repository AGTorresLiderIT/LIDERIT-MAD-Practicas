report 50200 RepInformesVenta
{
    ApplicationArea = All;
    Caption = 'Informe de ventas agrupado por cliente';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = 'Ejercicios11Mar\Report.rdl';
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
            //column(; "Currency Code") { }
            column(Amount; "Amount Including VAT") { }

            //dataitem()
            //{

            //}
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
}


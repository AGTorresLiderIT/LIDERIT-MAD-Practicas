report 50000 "Pedidos Venta Agrupado Cliente"
{
    ApplicationArea = All;
    Caption = 'Pedidos Venta agrupado por Cliente';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = './src/report/layout/PedidosVentaAgrupado.rdl';


    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = where("Document Type" = const(Order));
            column(nombreSociedad; informacionEmpresa.Name) { }
            column(Logo; informacionEmpresa.Picture) { }

            column(codigoCliente; "Sell-to Customer No.") { } // Código cliente
            column(nombreCliente; "Sell-to Customer Name") { } // Nombre cliente

            column(No; "No.")
            {
                IncludeCaption = true;
            }
            column(ExternalDocumentNo; "External Document No.")
            {
                IncludeCaption = true;
            }
            column(pais; "Sell-to Country/Region Code")
            {
                IncludeCaption = true;
            }
            column(poblacion; "Sell-to City")
            {
                IncludeCaption = true;
            }
            column(fecharegistro; "Posting Date")
            {
                IncludeCaption = true;
            }
            column(divisa; "Currency Code")
            {
                IncludeCaption = true;
            }
            column(importeDivisa; Amount)
            {
                IncludeCaption = true;
            }
            column(importeDivisaLocal; importeDivisaLocal) { }
            column(importeDivisaLocalLbl; importeDivisaLocalLbl) { }

            trigger OnAfterGetRecord()
            var
                confContabilidad: Record "General Ledger Setup";
            begin
                confContabilidad.Get();
                if "Currency Code" = '' then
                    "Currency Code" := confContabilidad."LCY Code";
                if "Currency Factor" = 0 then
                    importeDivisaLocal := Amount
                else
                    importeDivisaLocal := Amount * "Currency Factor";
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
        informacionEmpresa.Get();
        informacionEmpresa.CalcFields(Picture);
    end;

    var
        informacionEmpresa: Record "Company Information";
        importeDivisaLocal: Decimal;
        importeDivisaLocalLbl: Label 'Importe divisa local';
}

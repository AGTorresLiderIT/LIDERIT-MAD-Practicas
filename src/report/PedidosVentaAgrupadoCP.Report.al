report 50001 "Pedidos Venta Agrupado CP"
{
    ApplicationArea = All;
    Caption = 'Pedidos Venta agrupado por Cliente';
    UsageCategory = ReportsAndAnalysis;
    RDLCLayout = './src/report/layout/PedidosVentaAgrupadoCP.rdl';


    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = where("Document Type" = const(Order));
            column(nombreSociedad; informacionEmpresa.Name) { }
            column(Logo; informacionEmpresa.Picture) { }
            column(albaranLbl; albaranLbl) { }
            column(albaranLinesLbl; albaranLinesLbl) { }

            column(CodigoPostal; "Ship-to Post Code")
            {
                IncludeCaption = true;
            }
            column(poblacion; "Ship-to City")
            {
                IncludeCaption = true;
            }
            column(provincia; "Ship-to County")
            {
                IncludeCaption = true;
            }

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

            dataitem("Sales Shipment Header"; "Sales Shipment Header")
            {
                DataItemLinkReference = SalesHeader;
                DataItemLink = "Order No." = field("No.");
                column(albaranNo; "No.")
                {
                    IncludeCaption = true;
                }
                column(albaranCountLines; contarLineasAlbaran())
                {

                }
            }

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

    procedure contarLineasAlbaran(): Integer
    var
        salesShipmentLines: Record "Sales Shipment Line";
    begin
        salesShipmentLines.SetRange("No.", "Sales Shipment Header"."No.");
        exit(salesShipmentLines.Count());
    end;

    var
        informacionEmpresa: Record "Company Information";
        importeDivisaLocal: Decimal;
        importeDivisaLocalLbl: Label 'Importe divisa local';
        albaranLbl: Label 'Albaranes';
        albaranLinesLbl: Label 'Lines';
}

report 50001 "Comm. Settlement_LDR"
{
    ApplicationArea = All;
    Caption = 'Commission Settlement', Comment = 'ESP="Liquidación de comisiones"';
    DefaultRenderingLayout = RDLCLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        // RF-5.3: filters by settlement no. and salesperson.
        dataitem(CommissionSettlement; "Comm. Settlement_LDR")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Salesperson Code";

            // RF-5.1: header.
            column(CompanyName; CompanyInformation.Name) { }
            column(CompanyPicture; CompanyInformation.Picture) { }
            column(SettlementNo; CommissionSettlement."No.") { IncludeCaption = true; }
            column(SalespersonCode; CommissionSettlement."Salesperson Code") { IncludeCaption = true; }
            column(SalespersonName; SalespersonName) { }
            column(UpToDate; Format(CommissionSettlement."Up To Date")) { }
            column(TotalAmount; CommissionSettlement."Total Amount (LCY)") { IncludeCaption = true; }

            // RF-5.2: lines.
            dataitem(CommissionEntry; "Commission Entry_LDR")
            {
                DataItemLink = "Liquidation No." = field("No.");
                DataItemTableView = sorting("Liquidation No.");

                column(PostingDate; Format(CommissionEntry."Posting Date")) { }
                column(DocumentType; Format(CommissionEntry."Document Type")) { }
                column(DocumentNo; CommissionEntry."Document No.") { IncludeCaption = true; }
                column(CustomerNo; CommissionEntry."Customer No.") { IncludeCaption = true; }
                column(ItemNo; CommissionEntry."Item No.") { IncludeCaption = true; }
                column(BaseAmount; CommissionEntry."Base Amount (LCY)") { IncludeCaption = true; }
                column(CommissionPct; CommissionEntry."Commission %") { IncludeCaption = true; }
                column(CommissionAmount; CommissionEntry."Commission Amount (LCY)") { IncludeCaption = true; }
            }

            trigger OnAfterGetRecord()
            var
                SalespersonPurchaser: Record "Salesperson/Purchaser";
            begin
                CommissionSettlement.CalcFields("Total Amount (LCY)");
                SalespersonName := '';
                SalespersonPurchaser.SetLoadFields(Name);
                if SalespersonPurchaser.Get(CommissionSettlement."Salesperson Code") then
                    SalespersonName := SalespersonPurchaser.Name;
            end;
        }
    }

    rendering
    {
        layout(RDLCLayout)
        {
            Caption = 'Commission settlement (RDLC)', Comment = 'ESP="Liquidación de comisiones (RDLC)"';
            LayoutFile = './src/report/layout/CommissionSettlement.rdlc';
            Type = RDLC;
        }
    }

    labels
    {
        ReportTitleLbl = 'Commission Settlement', Comment = 'ESP="Liquidación de comisiones"';
        SalespersonNameLbl = 'Name', Comment = 'ESP="Nombre"';
        UpToDateLbl = 'Up To Date', Comment = 'ESP="Fecha hasta"';
        PostingDateLbl = 'Posting Date', Comment = 'ESP="Fecha registro"';
        DocumentTypeLbl = 'Document Type', Comment = 'ESP="Tipo documento"';
        TotalLbl = 'Total', Comment = 'ESP="Total"';
        PageLbl = 'Page', Comment = 'ESP="Página"';
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        CompanyInformation.CalcFields(Picture);
    end;

    var
        CompanyInformation: Record "Company Information";
        SalespersonName: Text[50];
}

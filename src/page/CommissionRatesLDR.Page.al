page 50004 "Commission Rates_LDR"
{
    // TF0022 RF-1.2: editable list of commission rates. Opened from the salesperson card (filtered by the
    // salesperson) or from Tell Me (all rates).
    ApplicationArea = All;
    Caption = 'Commission Rates', Comment = 'ESP="Tarifas de comisión"';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Commission Rate_LDR";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Rates)
            {
                field("Salesperson Code"; Rec."Salesperson Code") { }
                field("Item Category Code"; Rec."Item Category Code") { }
                field("Starting Date"; Rec."Starting Date") { }
                field("Commission %"; Rec."Commission %") { }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            // TF0022 RF-3.1: the action only calls the import codeunit.
            action(ImportFromExcel)
            {
                Caption = 'Import from Excel', Comment = 'ESP="Importar desde Excel"';
                Image = ImportExcel;
                ToolTip = 'Import commission rates from an Excel file with four columns (salesperson, item category, commission %, starting date) and the headers in row 1.', Comment = 'ESP="Importa tarifas de comisión desde un fichero Excel de cuatro columnas (vendedor, categoría, % comisión, fecha inicio) con las cabeceras en la fila 1."';

                trigger OnAction()
                var
                    CommissionRateImport: Codeunit "Commission Rate Import_LDR";
                begin
                    CommissionRateImport.ImportFromExcel();
                    CurrPage.Update(false);
                end;
            }
        }
        area(Promoted)
        {
            actionref(ImportFromExcel_Promoted; ImportFromExcel) { }
        }
    }
}

page 50000 "Commission Entries_LDR"
{
    ApplicationArea = All;
    Caption = 'Commission Entries', Comment = 'ESP="Movimientos de comisión"';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Commission Entry_LDR";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("Posting Date"; Rec."Posting Date") { }
                field("Document Type"; Rec."Document Type") { }
                field("Document No."; Rec."Document No.") { }
                field("Document Line No."; Rec."Document Line No.") { }
                field("Salesperson Code"; Rec."Salesperson Code") { }
                field("Customer No."; Rec."Customer No.") { }
                field("Item No."; Rec."Item No.") { }
                field("Base Amount (LCY)"; Rec."Base Amount (LCY)") { }
                field("Commission %"; Rec."Commission %") { }
                field("Commission Amount (LCY)"; Rec."Commission Amount (LCY)") { }
                field(Liquidated; Rec.Liquidated) { }
                field("Liquidation No."; Rec."Liquidation No.") { }
                field("User ID"; Rec."User ID") { }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Navigate)
            {
                Caption = 'Find entries...', Comment = 'ESP="Navegar..."';
                Image = Navigate;
                ShortcutKey = 'Ctrl+Alt+Q';
                ToolTip = 'Find entries and documents that exist for the document number and posting date of the selected entry.', Comment = 'ESP="Busca los movimientos y documentos que existen para el número de documento y la fecha de registro del movimiento seleccionado."';

                trigger OnAction()
                var
                    Navigate: Page Navigate;
                begin
                    Navigate.SetDoc(Rec."Posting Date", Rec."Document No.");
                    Navigate.Run();
                end;
            }
            // TF0022 RF-4.1: exports the entries with the filters the user has applied on the page.
            action(ExportToExcel)
            {
                Caption = 'Export to Excel', Comment = 'ESP="Exportar a Excel"';
                Image = ExportToExcel;
                ToolTip = 'Export the filtered commission entries to an Excel file with the salesperson and customer names.', Comment = 'ESP="Exporta a un fichero Excel los movimientos de comisión filtrados, con los nombres de vendedor y cliente."';

                trigger OnAction()
                var
                    CommissionMgt: Codeunit "Commission Mgt._LDR";
                begin
                    if not CommissionMgt.ExportToExcel(Rec) then
                        Message(NoEntriesToExportMsg);
                end;
            }
            // TF0022 RF-5.1: CSV file for payroll with the same filtered entries.
            action(ExportPayrollFile)
            {
                Caption = 'Export payroll file', Comment = 'ESP="Exportar fichero nóminas"';
                Image = ExportFile;
                ToolTip = 'Export the filtered commission entries to the CSV file of the payroll program.', Comment = 'ESP="Exporta los movimientos de comisión filtrados al fichero CSV del programa de nóminas."';

                trigger OnAction()
                var
                    CommissionMgt: Codeunit "Commission Mgt._LDR";
                begin
                    if not CommissionMgt.ExportPayrollFile(Rec) then
                        Message(NoEntriesToExportMsg);
                end;
            }
        }
        area(Promoted)
        {
            actionref(Navigate_Promoted; Navigate) { }
            actionref(ExportToExcel_Promoted; ExportToExcel) { }
            actionref(ExportPayrollFile_Promoted; ExportPayrollFile) { }
        }
    }

    var
        NoEntriesToExportMsg: Label 'There are no commission entries to export with the current filters.', Comment = 'ESP="No hay movimientos de comisión que exportar con los filtros actuales."';
}

page 50005 "Commission Import Errors_LDR"
{
    // TF0022 RF-3.3: read-only list of the rows that were not imported.
    ApplicationArea = All;
    Caption = 'Commission Rate Import Errors', Comment = 'ESP="Errores de importación de tarifas"';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Commission Import Error_LDR";
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Errors)
            {
                field("Row No."; Rec."Row No.") { }
                field("Row Text"; Rec."Row Text") { }
                field(Reason; Rec.Reason) { }
            }
        }
    }

    procedure SetErrors(var TempCommissionImportError: Record "Commission Import Error_LDR" temporary)
    begin
        Rec.Copy(TempCommissionImportError, true);
    end;
}

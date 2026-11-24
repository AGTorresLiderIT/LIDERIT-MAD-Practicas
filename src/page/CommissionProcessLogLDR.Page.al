page 50007 "Commission Process Log_LDR"
{
    // TF0023 RF-2.2: read-only log of the automatic settlement, most recent first.
    ApplicationArea = All;
    Caption = 'Commission Process Log', Comment = 'ESP="Registro del proceso de comisiones"';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    SourceTable = "Commission Process Log_LDR";
    SourceTableView = sorting("Entry No.") order(descending);
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("Run ID"; Rec."Run ID") { }
                field("Start Date-Time"; Rec."Start Date-Time") { }
                field("End Date-Time"; Rec."End Date-Time") { }
                field("Salesperson Code"; Rec."Salesperson Code") { }
                field(Status; Rec.Status) { }
                field("Settlement No."; Rec."Settlement No.") { }
                field(Message; Rec.Message) { }
                field("User ID"; Rec."User ID") { }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(OpenSettlement)
            {
                Caption = 'Open Settlement', Comment = 'ESP="Abrir liquidación"';
                Image = Document;
                ToolTip = 'Open the settlement created for the selected line.', Comment = 'ESP="Abre la liquidación creada en la línea seleccionada."';

                trigger OnAction()
                var
                    CommissionSettlement: Record "Comm. Settlement_LDR";
                begin
                    Rec.TestField("Settlement No.");
                    CommissionSettlement.SetRange("No.", Rec."Settlement No.");
                    Page.Run(Page::"Commission Settlements_LDR", CommissionSettlement);
                end;
            }
        }
        area(Promoted)
        {
            actionref(OpenSettlement_Promoted; OpenSettlement) { }
        }
    }
}

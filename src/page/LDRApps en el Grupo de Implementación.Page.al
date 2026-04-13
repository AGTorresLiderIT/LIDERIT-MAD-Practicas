page 50007 "Deployment Group Apps"
{
    PageType = ListPart;
    SourceTable = "App Deployment Staging";
    SourceTableView = sorting("Deployment Group", "Sequence No.");
    Caption = 'Apps en el Grupo de Implementación';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                    Caption = 'Nº de Secuencia';
                    ToolTip = 'Deployment sequence';
                    StyleExpr = StatusStyleExpr;
                }
                field("App File Name"; Rec."App File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre del Archivo de App';
                    ToolTip = 'App file name';
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre de la App';
                    ToolTip = 'App name';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Estado';
                    ToolTip = 'Current status';
                    StyleExpr = StatusStyleExpr;
                }
                field("Depends On Entry No."; Rec."Depends On Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Depende del Movimiento Nº';
                    ToolTip = 'Depends on entry';
                }
                field("Wait for Completion"; Rec."Wait for Completion")
                {
                    ApplicationArea = All;
                    Caption = 'Esperar la finalización';
                    ToolTip = 'Wait for completion';
                }
                field("Deployed Date Time"; Rec."Deployed Date Time")
                {
                    ApplicationArea = All;
                    Caption = 'Fecha y Hora de Implementación';
                    ToolTip = 'Deployment time';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateStatusStyle();
    end;

    local procedure UpdateStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Deployed:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Failed:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::"Installation In Progress", Rec.Status::"Upload Started",
            Rec.Status::"Upload Completed", Rec.Status::"Waiting for Dependencies":
                StatusStyleExpr := 'Ambiguous';
            else
                StatusStyleExpr := 'Standard';
        end;
    end;

    var
        StatusStyleExpr: Text;
}
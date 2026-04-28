page 50004 "Deployment Groups"
{
    PageType = List;
    SourceTable = "App Deployment Staging";
    SourceTableView = sorting("Deployment Group", "Sequence No.");
    Caption = 'Grupos de Implementación';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)//Todos los captions en español
            {
                field("Deployment Group"; Rec."Deployment Group")
                {
                    ApplicationArea = All;
                    Caption = 'Grupo de Implementación';
                    ToolTip = 'Deployment group identifier';
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                    Caption = 'Nº de Secuencia';
                    ToolTip = 'Deployment sequence within the group';
                }
                field("App File Name"; Rec."App File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre del Archivo de App';
                    ToolTip = 'App file name';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Estado';
                    ToolTip = 'Current deployment status';
                    StyleExpr = StatusStyleExpr;
                }
                field("Depends On Entry No."; Rec."Depends On Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Depende del Movimiento Nº';
                    ToolTip = 'Entry number of dependent app';
                }
                field("Wait for Completion"; Rec."Wait for Completion")
                {
                    ApplicationArea = All;
                    Caption = 'Esperar la finalización';
                    ToolTip = 'Wait for this app to complete before deploying next';
                }
                field("Scheduled Date"; Rec."Scheduled Date")
                {
                    Caption = 'Fecha Programada';
                    ApplicationArea = All;
                }
                field("Scheduled Time"; Rec."Scheduled Time")
                {
                    Caption = 'Hora Programada';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateNewGroup)
            {
                Caption = 'Crear Nuevo Grupo';
                Image = NewDocument;
                ApplicationArea = All;
                ToolTip = 'Create a new deployment group';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    GroupWizard: Page "Deployment Group Wizard";
                begin
                    GroupWizard.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(DeployGroup)
            {
                Caption = 'Publicar Grupo Ahora';
                Image = Start;
                ApplicationArea = All;
                ToolTip = 'Deploy all apps in the selected group immediately';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    if Rec."Deployment Group" = '' then
                        Error('Please select a deployment group.');

                    if Confirm('Deploy all apps in group %1 now?', false, Rec."Deployment Group") then begin
                        AppDeploymentMgt.DeployGroup(Rec."Deployment Group");
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(ViewGroupDetails)
            {
                Caption = 'Ver Detalles del Grupo';
                Image = View;
                ApplicationArea = All;
                ToolTip = 'View detailed information about the group';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    GroupDetail: Page "Deployment Group Detail";
                begin
                    if Rec."Deployment Group" = '' then
                        Error('Please select a deployment group.');

                    GroupDetail.SetGroupCode(Rec."Deployment Group");
                    GroupDetail.RunModal();
                end;
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

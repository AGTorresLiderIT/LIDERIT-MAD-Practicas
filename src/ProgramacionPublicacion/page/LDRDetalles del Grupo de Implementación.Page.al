page 50006 "Deployment Group Detail"
{
    PageType = Card;
    Caption = 'Detalles del Grupo de Implementación';
    SourceTable = "App Deployment Staging";
    SourceTableView = sorting("Deployment Group", "Sequence No.");

    layout
    {
        area(Content)
        {
            group(GroupInfo)
            {
                Caption = 'Group Information';

                field("Deployment Group"; GroupCode)
                {
                    ApplicationArea = All;
                    Caption = 'Código del Grupo';
                    Editable = false;
                }
                field(TotalApps; TotalApps)
                {
                    ApplicationArea = All;
                    Caption = 'Total de Apps';
                    Editable = false;
                }
                field(CompletedApps; CompletedApps)
                {
                    ApplicationArea = All;
                    Caption = 'Completados';
                    Editable = false;
                    Style = Favorable;
                }
                field(FailedApps; FailedApps)
                {
                    ApplicationArea = All;
                    Caption = 'Fallidos';
                    Editable = false;
                    Style = Unfavorable;
                }
                field(PendingApps; PendingApps)
                {
                    ApplicationArea = All;
                    Caption = 'Pendientes';
                    Editable = false;
                }
            }
            part(AppsList; "Deployment Group Apps")
            {
                ApplicationArea = All;
                SubPageLink = "Deployment Group" = field("Deployment Group");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeployGroup)
            {
                Caption = 'Publicar Grupo Ahora';
                Image = Start;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    if Confirm('Deploy all apps in this group now?', false) then begin
                        AppDeploymentMgt.DeployGroup(GroupCode);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(RefreshStatus)
            {
                Caption = 'Actualizar Estado';
                Image = Refresh;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    UpdateStatistics();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    procedure SetGroupCode(NewGroupCode: Code[20])
    begin
        GroupCode := NewGroupCode;
        Rec.SetRange("Deployment Group", GroupCode);
        if Rec.FindFirst() then;
        UpdateStatistics();
    end;

    local procedure UpdateStatistics()
    var
        AppDeployment: Record "App Deployment Staging";
    begin
        AppDeployment.SetRange("Deployment Group", GroupCode);
        TotalApps := AppDeployment.Count();

        AppDeployment.SetRange(Status, AppDeployment.Status::Deployed);
        CompletedApps := AppDeployment.Count();

        AppDeployment.SetRange(Status, AppDeployment.Status::Failed);
        FailedApps := AppDeployment.Count();

        AppDeployment.SetRange(Status, AppDeployment.Status::Pending);
        PendingApps := AppDeployment.Count();
    end;

    var
        GroupCode: Code[20];
        TotalApps: Integer;
        CompletedApps: Integer;
        FailedApps: Integer;
        PendingApps: Integer;

    trigger OnAfterGetRecord()
    begin
        UpdateStatistics();
    end;
}
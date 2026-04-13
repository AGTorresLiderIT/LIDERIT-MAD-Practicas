page 50003 "App Deployment Card"
{
    PageType = Card;
    SourceTable = "App Deployment Staging";
    Caption = 'Detalles de la implementación de apps';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Caption = 'Número de Entrada';
                    ToolTip = 'Specifies the entry number.';
                    Editable = false;
                }
                field("App File Name"; Rec."App File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre del Archivo de la App';
                    ToolTip = 'Specifies the app file name.';
                    Editable = false;
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre de la App';
                    ToolTip = 'Specifies the app name.';
                    // Editable = false;
                    ShowMandatory = true;
                }
                field("Deployment Type"; Rec."Deployment Type")
                {
                    ApplicationArea = All;
                    Caption = 'Tipo de Implementación';
                    ToolTip = 'Specifies the deployment type.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Estado';
                    ToolTip = 'Specifies the deployment status.';
                    Editable = false;
                    StyleExpr = StatusStyleExpr;
                }
            }
            group(Schedule)
            {
                Caption = 'Programación';

                field("Scheduled Date"; Rec."Scheduled Date")
                {
                    ApplicationArea = All;
                    Caption = 'Fecha Programada';
                    ToolTip = 'Specifies the scheduled deployment date.';
                }
                field("Scheduled Time"; Rec."Scheduled Time")
                {
                    ApplicationArea = All;
                    Caption = 'Hora Programada';
                    ToolTip = 'Specifies the scheduled deployment time.';
                }
            }
            group(EmailNotification)
            {
                Caption = 'Notificación por Email';

                field("Send Email on Completion"; Rec."Send Email on Completion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to send email notification when deployment completes.';
                }
                field("Email Recipients"; Rec."Email Recipients")
                {
                    ApplicationArea = All;
                    Caption = 'Destinatarios del Email';
                    ToolTip = 'Semicolon-separated email addresses (e.g., user1@company.com;user2@company.com)';
                    MultiLine = true;
                }
            }
            group(Details)
            {
                Caption = 'Detalles de Implementación';

                field("Operation ID"; Rec."Operation ID")
                {
                    ApplicationArea = All;
                    Caption = 'ID de Operación';
                    ToolTip = 'Specifies the operation ID from NAV App Tenant Operation.';
                    Editable = false;
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                    ApplicationArea = All;
                    Caption = 'Fecha y Hora de Creación';
                    ToolTip = 'Specifies when the entry was created.';
                    Editable = false;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    Caption = 'Creado Por';
                    ToolTip = 'Specifies who created the entry.';
                    Editable = false;
                }
                field("Deployed Date Time"; Rec."Deployed Date Time")
                {
                    ApplicationArea = All;
                    Caption = 'Fecha y Hora de Implementación';
                    ToolTip = 'Specifies when the app was deployed or failed.';
                    Editable = false;
                }
                field("Last Status Check"; Rec."Last Status Check")
                {
                    ApplicationArea = All;
                    Caption = 'Última Verificación de Estado';
                    ToolTip = 'Specifies when the status was last checked.';
                    Editable = false;
                }
            }
            group(ErrorInfo)
            {
                Caption = 'Información de Error';
                Visible = ShowErrorInfo;

                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any error message.';
                    Editable = false;
                    MultiLine = true;
                    StyleExpr = 'Unfavorable';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeployNow)
            {
                Caption = 'Publicar Ahora';
                Image = Start;
                ApplicationArea = All;
                ToolTip = 'Deploy the app immediately.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    if Rec.Status <> Rec.Status::Pending then
                        Error('Only pending deployments can be executed manually.');

                    if Confirm('Do you want to deploy this app now?', false) then begin
                        AppDeploymentMgt.DeployApp(Rec);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(RefreshStatus)
            {
                Caption = 'Actualizar Estado';
                Image = Refresh;
                ApplicationArea = All;
                ToolTip = 'Manually refresh the deployment status.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                    Message('Status refreshed.');
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateVisibility();
    end;

    local procedure UpdateVisibility()
    begin
        ShowErrorInfo := (Rec.Status = Rec.Status::Failed) and (Rec."Error Message" <> '');

        case Rec.Status of
            Rec.Status::Deployed:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Failed:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::"Installation In Progress", Rec.Status::"Upload Started", Rec.Status::"Upload Completed":
                StatusStyleExpr := 'Ambiguous';
            else
                StatusStyleExpr := 'Standard';
        end;
    end;

    var
        ShowErrorInfo: Boolean;
        StatusStyleExpr: Text;
}
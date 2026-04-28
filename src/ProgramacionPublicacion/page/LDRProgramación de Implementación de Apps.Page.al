page 50002 "App Deployment Staging"
{
    PageType = List;
    SourceTable = "App Deployment Staging";
    Caption = 'Programación de Implementación de Apps';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "App Deployment Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number.';
                }
                field("App File Name"; Rec."App File Name")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre Archivo App';
                    ToolTip = 'Especifica el nombre del archivo de la aplicación.';
                    StyleExpr = StatusStyleExpr;
                }
                field("File Deleted After Upload"; Rec."File Deleted After Upload")
                {
                    ApplicationArea = All;
                    Caption = 'Archivo Eliminado tras Subida';
                    ToolTip = 'El archivo fue eliminado por seguridad después de subirlo.';
                    Style = Attention;
                }
                field("File Hash"; Rec."File Hash")
                {
                    ApplicationArea = All;
                    Caption = 'Hash de Archivo';
                    ToolTip = 'Hash SHA256 para la verificación del archivo.';
                    Visible = false;
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    Caption = 'Nombre de la App';
                    ShowMandatory = true;
                    ToolTip = 'Especifica el nombre de la aplicación a partir de la operación.';
                }
                field("Scheduled Date"; Rec."Scheduled Date")
                {
                    ApplicationArea = All;
                    Caption = 'Fecha Programada';
                    ToolTip = 'Especifica la fecha programada para el despliegue.';
                }
                field("Scheduled Time"; Rec."Scheduled Time")
                {
                    ApplicationArea = All;
                    Caption = 'Hora Programada';
                    ToolTip = 'Especifica la hora programada para el despliegue.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Estado';
                    ToolTip = 'Especifica el estado actual del despliegue.';
                    StyleExpr = StatusStyleExpr;
                }
                field("Deployment Type"; Rec."Deployment Type")
                {
                    ApplicationArea = All;
                    Caption = 'Tipo de Despliegue';
                    ToolTip = 'Especifica el tipo de despliegue.';
                }
                field("Send Email on Completion"; Rec."Send Email on Completion")
                {
                    ApplicationArea = All;
                    Caption = 'Enviar Email al Finalizar';
                    ToolTip = 'Especifica si se enviará una notificación por correo electrónico al terminar.';
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                    ApplicationArea = All;
                    Caption = 'Fecha/Hora de Creación';
                    ToolTip = 'Especifica cuándo se creó el registro.';
                }
                field("Deployed Date Time"; Rec."Deployed Date Time")
                {
                    ApplicationArea = All;
                    Caption = 'Fecha/Hora de Despliegue';
                    ToolTip = 'Especifica cuándo se desplegó la aplicación.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    Caption = 'Creado por';
                    ToolTip = 'Especifica el usuario que creó el registro.';
                }
            }
        }
        area(FactBoxes)
        {
            part(ErrorDetails; "App Deploy Error FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadAppFile)
            {
                Caption = 'Subir Archivo de App';
                Image = Import;
                ApplicationArea = All;
                ToolTip = 'Upload an app file for scheduled deployment.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    FileInStream: InStream;
                    FileName: Text;
                begin
                    if UploadIntoStream('Select App File', '', 'App Files (*.app)|*.app', FileName, FileInStream) then begin
                        Rec.SetAppFile(FileInStream, FileName);
                        Rec.Insert(true);
                        Message('App file uploaded successfully. Entry No. %1\n\nPlease set the schedule and email recipients.', Rec."Entry No.");
                    end;
                end;
            }
            action(DeployNow)
            {
                Caption = 'Publicar Ahora';
                Image = Start;
                ApplicationArea = All;
                ToolTip = 'Deploy the selected app immediately.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    if Rec.Status <> Rec.Status::Pending then
                        Error('Only pending deployments can be executed manually.');

                    if Rec."File Deleted After Upload" then
                        Error('App file has been deleted for security. Please re-upload the file using "Re-upload App File" action.');

                    if Confirm('Do you want to deploy this app now?', false) then begin
                        AppDeploymentMgt.DeployApp(Rec);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(ReuploadAppFile)
            {
                Caption = 'Re-subir Archivo de App';
                Image = Import;
                ApplicationArea = All;
                ToolTip = 'Re-upload the app file (if it was deleted for security)';
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec."File Deleted After Upload";

                trigger OnAction()
                var
                    FileInStream: InStream;
                    FileName: Text;
                begin
                    if not Rec."File Deleted After Upload" then
                        Error('File is still available. No need to re-upload.');

                    if UploadIntoStream('Select App File', '', 'App Files (*.app)|*.app', FileName, FileInStream) then begin
                        Rec.SetAppFile(FileInStream, FileName);
                        Rec.Modify(true);
                        Message('App file re-uploaded successfully. You can now deploy.');
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(RefreshStatus)
            {
                Caption = 'Actualizar Estado';
                Image = Refresh;
                ApplicationArea = All;
                ToolTip = 'Manually refresh the status of the selected deployment.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()

                begin
                    // AppDeploymentMgt.CheckOperationStatus(Rec);
                    CurrPage.Update(false);
                    Message('Status refreshed.');
                end;
            }
            action(ViewOperationDetails)
            {
                Caption = 'Ver en Gestion de Extensiones';
                Image = View;
                ApplicationArea = All;
                ToolTip = 'Open Extension Management to view deployment details.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    AppDeploymentMgt.OpenExtensionManagement();
                end;
            }
            action(SetupJobQueue)
            {
                Caption = 'Configurar Cola de Trabajo';
                Image = Setup;
                ApplicationArea = All;
                ToolTip = 'Setup the job queue for automatic deployment.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    AppDeploymentMgt.SetupJobQueue();
                end;
            }
            action(CreateDeploymentGroup)
            {
                Caption = 'Crear Grupo de Despliegue';
                Image = NewDocument;
                ApplicationArea = All;
                ToolTip = 'Create a new deployment group for sequential app deployment';
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    GroupWizard: Page "Deployment Group Wizard";
                begin
                    GroupWizard.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(ViewDeploymentGroups)
            {
                Caption = 'Ver Grupos';
                Image = Group;
                ApplicationArea = All;
                ToolTip = 'View and manage deployment groups';
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    DeploymentGroups: Page "Deployment Groups";
                begin
                    DeploymentGroups.Run();
                end;
            }
            action(ViewExtensionManagement)
            {
                Caption = 'Gestión de Extensiones';
                Image = Setup;
                ApplicationArea = All;
                ToolTip = 'Open Extension Management page to view all extensions and their status.';
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    AppDeploymentMgt.OpenExtensionManagement();
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
            Rec.Status::"Installation In Progress", Rec.Status::"Upload Started", Rec.Status::"Upload Completed":
                StatusStyleExpr := 'Ambiguous';
            else
                StatusStyleExpr := 'Standard';
        end;
    end;

    var
        StatusStyleExpr: Text;
}
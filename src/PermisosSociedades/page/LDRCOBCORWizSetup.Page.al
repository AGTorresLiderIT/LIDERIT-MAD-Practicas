page 50026 COBCORWizSetup
{
    ApplicationArea = All;
    Caption = 'Wizard Setup', Comment = 'ESP="Configuración Wizard Usuarios"';
    PageType = Card;
    SourceTable = COBCORWizSetup;
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;


    layout
    {
        area(Content)
        {
            group(COBCORGeneral)
            {
                Caption = 'General', Comment = 'ESP="General"';

                field(COBCORPrimaryKey; Rec.COBCORPrimaryKey)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the setup primary key.', Comment = 'ESP="Especifica la clave primaria de configuración"';
                }
                field(COBCORNubeAllPermission; Rec.COBCORNubeAllPermission)
                {
                    ApplicationArea = All;
                    Caption = 'NUBE-ALL Permission', Comment = 'ESP="Permiso NUBE-ALL"';
                    ToolTip = 'Specifies the permission set used as the NUBE-ALL role in Wizard processes.', Comment = 'ESP="Especifica el grupo de permisos usado como rol NUBE-ALL en los procesos del Wizard"';
                }
                field(COBCORJefeContazonaPermission; Rec.COBCORJefeContaPermission)
                {
                    ApplicationArea = All;
                    Caption = 'JEFE-CONTAZONA Permission', Comment = 'ESP="Permiso JEFE-CONTAZONA "';
                    ToolTip = 'Specifies the permission set used as the JEFE-CONTAZONA role in Wizard processes.', Comment = 'ESP="Especifica el grupo de permisos usado como rol NUBE-ALL en los procesos del Wizard"';
                }
                field(COBCORReplicationTableNo; Rec.COBCORReplicationTableNo)
                {
                    ApplicationArea = All;
                    Caption = 'Replication Table No.', Comment = 'ESP="Nº Tabla Replicación"';
                    ToolTip = 'Indica el número de tabla para obtener las empresas desde replicación.', Comment = 'ESP="Indica el número de tabla para obtener las empresas desde replicación."';
                }
                field(COBCORDelegationDimension; Rec.COBCORDelegationDimension)
                {
                    ApplicationArea = All;
                    Caption = 'Delegation Dimension', Comment = 'ESP="Dimensión Delegación"';
                    ToolTip = 'Código de la dimensión que se usará como Delegación para los filtros de seguridad.', Comment = 'ESP="Código de la dimensión que se usará como Delegación para los filtros de seguridad."';
                }
                field(COBCORWelcomeEmailUrl; Rec.COBCORWelcomeEmailUrl)
                {
                    ApplicationArea = All;
                    Caption = 'Business Central URL', Comment = 'ESP="URL Business Central"';
                    ToolTip = 'Specifies the Business Central URL included in welcome emails.', Comment = 'ESP="Especifica la URL de Business Central incluida en los correos de bienvenida."';
                }
                field(COBCORWelcomeManualESName; Rec.COBCORWelcomeManualESName)
                {
                    ApplicationArea = All;
                    Caption = 'Spanish Manual Name', Comment = 'ESP="Nombre Manual Español"';
                    Editable = false;
                    ToolTip = 'Specifies the Spanish manual file currently configured for welcome emails.', Comment = 'ESP="Especifica el fichero de manual en español configurado actualmente para los correos de bienvenida."';
                }
                field(COBCORWelcomeManualENName; Rec.COBCORWelcomeManualENName)
                {
                    ApplicationArea = All;
                    Caption = 'English Manual Name', Comment = 'ESP="Nombre Manual Inglés"';
                    Editable = false;
                    ToolTip = 'Specifies the English manual file currently configured for welcome emails.', Comment = 'ESP="Especifica el fichero de manual en inglés configurado actualmente para los correos de bienvenida."';
                }
            }

            group(COBCORExtraRoles)
            {
                Caption = 'Extra Roles Setup', Comment = 'ESP="Configuración Roles Extra"';

                part(COBCORExtraRolesPart; COBCORWizRoleExtraSetupSubform)
                {
                    ApplicationArea = All;
                    Caption = 'Extra Roles', Comment = 'ESP="Roles Extra"';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(COBCORUploadWelcomeManualES)
            {
                ApplicationArea = All;
                Caption = 'Upload Spanish Manual', Comment = 'ESP="Cargar Manual Español"';
                Image = Import;
                ToolTip = 'Uploads the PDF manual attached to welcome emails in Spanish.', Comment = 'ESP="Carga el manual PDF que se adjuntará en los correos de bienvenida en español."';

                trigger OnAction()
                var
                    lFileName: Text;
                    lInStream: InStream;
                    lOutStream: OutStream;
                begin
                    if not UploadIntoStream(UploadManualLbl, '', AllowedFileTypesLbl, lFileName, lInStream) then
                        exit;

                    Clear(Rec.COBCORWelcomeManualES);
                    Rec.COBCORWelcomeManualES.CreateOutStream(lOutStream);
                    CopyStream(lOutStream, lInStream);
                    Rec.COBCORWelcomeManualESName := CopyStr(lFileName, 1, MaxStrLen(Rec.COBCORWelcomeManualESName));
                    Rec.Modify();
                end;
            }

            action(COBCORUploadWelcomeManualEN)
            {
                ApplicationArea = All;
                Caption = 'Upload English Manual', Comment = 'ESP="Cargar Manual Inglés"';
                Image = Import;
                ToolTip = 'Uploads the PDF manual attached to welcome emails in English.', Comment = 'ESP="Carga el manual PDF que se adjuntará en los correos de bienvenida en inglés."';

                trigger OnAction()
                var
                    lFileName: Text;
                    lInStream: InStream;
                    lOutStream: OutStream;
                begin
                    if not UploadIntoStream(UploadManualLbl, '', AllowedFileTypesLbl, lFileName, lInStream) then
                        exit;

                    Clear(Rec.COBCORWelcomeManualEN);
                    Rec.COBCORWelcomeManualEN.CreateOutStream(lOutStream);
                    CopyStream(lOutStream, lInStream);
                    Rec.COBCORWelcomeManualENName := CopyStr(lFileName, 1, MaxStrLen(Rec.COBCORWelcomeManualENName));
                    Rec.Modify();
                end;
            }

            action(COBCORDeleteWelcomeManualES)
            {
                ApplicationArea = All;
                Caption = 'Delete Spanish Manual', Comment = 'ESP="Borrar Manual Español"';
                Image = Delete;
                ToolTip = 'Removes the uploaded Spanish welcome manual.', Comment = 'ESP="Elimina el manual de bienvenida en español cargado actualmente."';

                trigger OnAction()
                begin
                    if not Confirm(DeleteManualQstLbl) then
                        exit;

                    Clear(Rec.COBCORWelcomeManualES);
                    Rec.COBCORWelcomeManualESName := '';
                    Rec.Modify();
                end;
            }

            action(COBCORDeleteWelcomeManualEN)
            {
                ApplicationArea = All;
                Caption = 'Delete English Manual', Comment = 'ESP="Borrar Manual Inglés"';
                Image = Delete;
                ToolTip = 'Removes the uploaded English welcome manual.', Comment = 'ESP="Elimina el manual de bienvenida en inglés cargado actualmente."';

                trigger OnAction()
                begin
                    if not Confirm(DeleteManualQstLbl) then
                        exit;

                    Clear(Rec.COBCORWelcomeManualEN);
                    Rec.COBCORWelcomeManualENName := '';
                    Rec.Modify();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        g_recUserSetup.get(UserId);
        if not Rec.FindFirst() then begin
            Rec.Init();
            Rec.COBCORPrimaryKey := '';
            Rec.COBCORNubeAllPermission := 'COB-NUBE-ALL';
            Rec.Insert();
            exit;
        end;

        if Rec.COBCORNubeAllPermission = '' then begin
            Rec.COBCORNubeAllPermission := 'COB-NUBE-ALL';
            Rec.Modify();
        end;
    end;

    var
        UploadManualLbl: Label 'Select the welcome manual to upload.', Comment = 'ESP="Seleccione el manual de bienvenida que desea cargar."';
        AllowedFileTypesLbl: Label 'PDF files (*.pdf)|*.pdf|All files (*.*)|*.*', Comment = 'ESP="Ficheros PDF (*.pdf)|*.pdf|Todos los ficheros (*.*)|*.*"';
        DeleteManualQstLbl: Label 'Are you sure you want to delete this manual?', Comment = 'ESP="¿Está seguro de que desea eliminar este manual?"';
        g_recUserSetup: Record "User Setup";

}
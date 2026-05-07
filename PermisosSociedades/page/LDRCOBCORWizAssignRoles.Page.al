page 50350 COBCORWizAssignRoles
{
    ApplicationArea = All;
    Caption = 'Wizard Assign Roles', Comment = 'ESP="Wizard Asignar Roles"';
    PageType = Card;
    SourceTable = COBCORWizUserConfigurationList;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            group(COBCORUserData)
            {
                Caption = 'User Data', Comment = 'ESP="Datos Usuarios"';

                field(COBCORUserID; Rec.COBCORUserID)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the User ID field.', Comment = 'ESP="ID Usuario"';
                }
                field(COBCORFullName; Rec.COBCORFullName)
                {
                    ApplicationArea = All;
                    Editable = BoolEditable;
                    ToolTip = 'Especifica el nombre completo del usuario.', Comment = 'ESP="Nombre completo"';
                }
                field(COBCOREmail; Rec.COBCOREmail)
                {
                    ApplicationArea = All;
                    Editable = BoolEditable;
                    ToolTip = 'Specifies the value of the Email field.', Comment = 'ESP="Correo Electrónico"';
                }
                field(COBCORDepartment; Rec.COBCORDepartment)
                {
                    ApplicationArea = All;
                    Editable = BoolEditable;
                    ToolTip = 'Specifies the value of the Department field.', Comment = 'ESP="Departamento"';
                }
                field(COBCORCountry; Rec.COBCORCountry)
                {
                    ApplicationArea = All;
                    Editable = BoolEditable;
                    ToolTip = 'Specifies the value of the Country field.', Comment = 'ESP="País"';
                }
                field(COBCORLanguage; Rec.COBCORLanguage)
                {
                    ApplicationArea = All;
                    Editable = BoolEditable;
                    ToolTip = 'Specifies the value of the Language field.', Comment = 'ESP="Idioma"';
                }
                field(COBCORConnection; Rec.COBCORConnection)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Connection field.', Comment = 'ESP="Conexión"';
                }
                field(COBCORLicenseType; Rec.COBCORLicenseType)
                {
                    ApplicationArea = All;
                    Editable = BoolEditable;
                    ToolTip = 'Specifies the value of the License Type field.', Comment = 'ESP="Tipo de licencias"';
                }
                field(COBCORResponsible; Rec.COBCORResponsible)
                {
                    ApplicationArea = All;
                    Editable = BoolEditable;
                    ToolTip = 'Specifies the value of the Registration Responsible field.', Comment = 'ESP="Responsable Alta"';
                }
                field(COBCORRegistrationDate; Rec.COBCORRegistrationDate)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Registration Date field.', Comment = 'ESP="Fecha de Alta"';
                }
                field(COBCOREasyVistaRegistration; Rec.COBCOREasyVistaRegistration)
                {
                    ApplicationArea = All;
                    Editable = BoolEditable;
                    ToolTip = 'Specifies the value of the EasyVista Registration field.', Comment = 'ESP="EasyVista Alta"';
                }
                field(COBCORDeactivated; Rec.COBCORDeactivated)
                {
                    ApplicationArea = All;
                    Editable = BoolEditable;
                    ToolTip = 'Specifies whether the user is deactivated.', Comment = 'ESP="Dado de Baja"';

                    trigger OnValidate()
                    begin
                        gCOBCORWizUsersMgt.HandleDeactivationChange(Rec, xRec.COBCORDeactivated);

                        if Rec.COBCORDeactivated <> xRec.COBCORDeactivated then
                            if Rec.COBCORDeactivated then
                                Message(UserDeactivatedMsgLbl, Rec.COBCORUserID)
                            else
                                Message(UserReactivatedMsgLbl, Rec.COBCORUserID);

                        ShowOptions := Rec.COBCORDeactivated;
                        CurrPage.Update(false);
                    end;
                }
                field(COBCOREasyVistaDeactivation; Rec.COBCOREasyVistaDeactivation)
                {
                    ApplicationArea = All;
                    Editable = BoolEditable;
                    ToolTip = 'Specifies the value of the EasyVista Deactivation field.', Comment = 'ESP="EasyVista Baja"';
                }
                field(COBCORDeactivationDate; Rec.COBCORDeactivationDate)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Deactivation Date field.', Comment = 'ESP="Fecha de Baja"';
                }
                field(COBCORDeactivationResponsible; Rec.COBCORDeactivationResponsible)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Deactivation Responsible field.', Comment = 'ESP="Responsable Baja"';
                }
            }

            group(COBCORRoleRegistration)
            {
                Caption = 'Role Registration', Comment = 'ESP="Registro de Roles"';

                field(COBCORTargetCompany; COBCORTargetCompany)
                {
                    ApplicationArea = All;
                    Caption = 'Company', Comment = 'ESP="Empresa"';
                    ToolTip = 'Specifies the target company for role registration.', Comment = 'ESP="Especifica la empresa destino para registrar el rol"';


                    trigger OnValidate()
                    begin
                        COBCORTargetDelegation := '';
                    end;
                }
                field(COBCORTargetRole; COBCORTargetRole)
                {
                    ApplicationArea = All;
                    Caption = 'Company Permission', Comment = 'ESP="Permiso Empresa"';
                    TableRelation = COBCORWizRolesCOBRAList."Role ID";
                    LookupPageId = COBCORWizRolesCobraList;
                    ToolTip = 'Specifies the role to register in the selected company.', Comment = 'ESP="Especifica el rol a registrar en la empresa seleccionada"';
                }
                field(COBCORTargetDelegation; COBCORTargetDelegation)
                {
                    ApplicationArea = All;
                    Caption = 'Delegation Filter', Comment = 'ESP="Filtro Delegación"';
                    ToolTip = 'Specifies the delegation filter for the role registration.', Comment = 'ESP="Especifica el filtro de delegación para el registro del rol"';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if gCOBCORWizUsersMgt.LookupDelegationValue(COBCORTargetCompany, COBCORTargetDelegation) then begin
                            Text := COBCORTargetDelegation;
                            exit(true);
                        end;

                        exit(false);
                    end;
                }
            }

            part(COBCORRolesPart; COBCORWizAssignRolesSubform)
            {
                ApplicationArea = All;
                Caption = 'Roles', Comment = 'ESP="Roles"';
                SubPageLink = COBCORUserID = FIELD(COBCORUserID);
            }
        }
    }

    actions
    {
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'ESP="Proceso"';

                actionref(COBCORRegisterRoleRef;
                COBCORRegisterRole)
                {
                }
                actionref(COBCORDeleteRolesRef; COBCORDeleteRoles)
                {
                }
            }
        }

        area(Processing)
        {
            action(COBCORMarkAll)
            {
                ApplicationArea = All;
                Caption = 'Mark All', Comment = 'ESP="Marcar Todos"';
                Image = SelectEntries;
                ToolTip = 'Marks all role lines of the current user for deletion.', Comment = 'ESP="Marca para eliminar todas las líneas de roles del usuario actual"';

                trigger OnAction()
                begin
                    gCOBCORWizUsersMgt.MarkAllRolesForUser(Rec.COBCORUserID, true);

                    CurrPage.Update(false);
                end;
            }

            action(COBCORUnmarkAll)
            {
                ApplicationArea = All;
                Caption = 'Unmark All', Comment = 'ESP="Desmarcar Todos"';
                Image = ClearFilter;
                ToolTip = 'Unmarks all role lines of the current user.', Comment = 'ESP="Desmarca todas las líneas de roles del usuario actual"';

                trigger OnAction()
                begin
                    gCOBCORWizUsersMgt.MarkAllRolesForUser(Rec.COBCORUserID, false);

                    CurrPage.Update(false);
                end;
            }

            action(COBCORDeleteRoles)
            {
                ApplicationArea = All;
                Caption = 'Delete Roles', Comment = 'ESP="Eliminar Roles"';
                Image = Delete;
                ToolTip = 'Deletes role lines marked for deletion for the current user.', Comment = 'ESP="Elimina las líneas de roles marcadas para borrar del usuario actual"';

                trigger OnAction()
                var
                    lDeletedCount: Integer;
                begin
                    if not Confirm(DeleteRolesQstLbl, true, Rec.COBCORUserID) then
                        Error(ProcessCanceledErrLbl);

                    lDeletedCount := gCOBCORWizUsersMgt.DeleteMarkedRolesForUser(Rec.COBCORUserID);
                    if lDeletedCount > 0 then
                        Message(UserRolesDeletedMsgLbl);
                    if lDeletedCount = 0 then
                        Message(NoRowsMarkedMsgLbl);

                    CurrPage.Update(false);
                end;
            }

            action(COBCORRegisterRole)
            {
                ApplicationArea = All;
                Caption = 'Register Roles', Comment = 'ESP="Registrar Roles"';
                Image = Create;
                ToolTip = 'Registers the selected role in the selected company for the current user.', Comment = 'ESP="Registra el rol seleccionado en la empresa seleccionada para el usuario actual"';

                trigger OnAction()
                begin
                    if Rec.COBCORDeactivated then
                        Error(UserIsDeactivatedErrLbl);

                    if (COBCORTargetCompany = '') or (COBCORTargetRole = '') then
                        Error(CompanyRoleRequiredErrLbl);

                    gCOBCORWizUsersMgt.RegisterRoleForUser(Rec.COBCORUserID, COBCORTargetCompany, COBCORTargetRole, COBCORTargetDelegation);

                    Message(ProcessFinishedMsgLbl);
                    CurrPage.Update(false);
                end;
            }
            action(COBCORCopyProfile)
            {
                ApplicationArea = All;
                Caption = 'Copy Profile', Comment = 'ESP="Copia de Perfil"';
                Image = Copy;
                ToolTip = 'Runs the profile copy process.', Comment = 'ESP="Ejecuta el proceso de copia de perfil"';

                trigger OnAction()
                var
                    l_pageWizCopiarPerfil: Page COBCORWizCopiaPerfil;
                begin
                    l_pageWizCopiarPerfil.SetDestinationUser(rec.COBCORUserID);
                    if l_pageWizCopiarPerfil.RunModal() = Action::LookupOK then;
                end;
            }
            action(COBCORUserLocalConfiguration)
            {
                ApplicationArea = All;
                Caption = 'Local User Configuration', Comment = 'ESP="Configuración local usuario"';
                Image = Setup;
                ToolTip = 'Opens local user configuration.', Comment = 'ESP="Abre la configuración local del usuario"';

                trigger OnAction()
                var
                    lUserConfigData: Record COBCORWizUserConfigurationData;
                    TempUserConfigData: Record COBCORWizUserConfigurationData temporary;
                    Setup: Record COBCORWizSetup;
                begin
                    if gCOBCORWizUsersMgt.IsSupportDepartment(Rec.COBCORDepartment) then
                        gCOBCORWizUsersMgt.InsertSupportCompanies(Rec.COBCORUserID);

                    if not Setup.Get() then
                        Error('No se ha configurado la tabla de replicado de empresas.');

                    lUserConfigData.Reset();
                    lUserConfigData.SetRange(COBCORUserID, Rec.COBCORUserID);

                    if lUserConfigData.FindSet() then
                        repeat
                            TempUserConfigData := lUserConfigData;
                            if TempUserConfigData.Insert() then;
                        until lUserConfigData.Next() = 0;

                    if not TempUserConfigData.IsEmpty() then
                        Page.RunModal(Page::COBCORPermisosCore, TempUserConfigData)
                    else
                        Error('No hay registros para mostrar');
                end;
            }
            action(COBCORSendWelcomeEmailPending)
            {
                ApplicationArea = All;
                Caption = 'Send Welcome Email', Comment = 'ESP="Enviar correo de Bienvenida"';
                Image = Email;
                ToolTip = 'Sends a welcome email in the user language with the configured manual attached.', Comment = 'ESP="Envía un correo de bienvenida en el idioma del usuario con el manual configurado adjunto."';

                trigger OnAction()
                begin
                    gCOBCORWizUsersMgt.SendWelcomeEmail(Rec);
                    Message(WelcomeEmailSentMsgLbl, Rec.COBCOREmail);
                end;
            }
            action(COBCORConfigureWipPending)
            {
                ApplicationArea = All;
                Caption = 'Configure WIP', Comment = 'ESP="Configurar obra gasto en curso"';
                Image = Setup;
                ToolTip = 'Pending migration action for WIP configuration.', Comment = 'ESP="Acción pendiente de migración para configuración de obra gasto en curso"';

                trigger OnAction()
                begin
                    Message(WipConfigurationPendingMsgLbl);
                end;
            }
            action(COBCORExtraRoleConfiguration)
            {
                ApplicationArea = All;
                Caption = 'Extra Role Configuration', Comment = 'ESP="Configuración de Roles Extra"';
                Image = SetupList;
                ToolTip = 'Opens the extra role setup for parent/child companies.', Comment = 'ESP="Abre la configuración de roles extra para matriz/hija"';

                trigger OnAction()
                begin
                    Page.RunModal(Page::COBCORWizSetup);
                end;
            }
            group(COBCOROptions)
            {
                Caption = 'Options', Comment = 'ESP="Opciones"';
                Visible = ShowOptions;

                action(COBCORRoleHistory)
                {
                    ApplicationArea = All;
                    Caption = 'Roles History', Comment = 'ESP="Historial Roles"';
                    Image = History;
                    ToolTip = 'Opens the role history for the current user.', Comment = 'ESP="Abre el historial de roles del usuario actual"';

                    trigger OnAction()
                    var
                        lRoleHistoryPage: Page COBCORWizRoleHistory;
                    begin
                        lRoleHistoryPage.SetUserFilter(Rec.COBCORUserID);
                        lRoleHistoryPage.RunModal();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ShowOptions := Rec.COBCORDeactivated;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        gCOBCORWizUsersMgt.ResetDeleteMarksForUser(Rec.COBCORUserID);
        exit(true);
    end;

    var
        //g_recUserSetup: Record "User Setup";
        gCOBCORWizUsersMgt: Codeunit COBCORWizUsersMgt;
        COBCORTargetCompany: Text[30];
        COBCORTargetRole: Code[20];
        COBCORTargetDelegation: Text[250];
        ShowOptions: Boolean;
        BoolEditable: Boolean;
        DeleteRolesQstLbl: Label 'Do you want to delete selected role lines for user %1?', Comment = 'ESP="¿Desea eliminar las líneas de roles seleccionadas para el usuario %1?"';
        ProcessCanceledErrLbl: Label 'Process canceled.', Comment = 'ESP="Proceso cancelado"';
        UserRolesDeletedMsgLbl: Label 'User role accesses were deleted.', Comment = 'ESP="Se han eliminado los accesos de rol del usuario"';
        NoRowsMarkedMsgLbl: Label 'No role lines are marked for deletion.', Comment = 'ESP="No hay líneas de rol marcadas para eliminar"';
        CompanyRoleRequiredErrLbl: Label 'Company and role are required to register roles.', Comment = 'ESP="Debe informar la empresa y el rol para registrar roles"';
        ProcessFinishedMsgLbl: Label 'Process completed.', Comment = 'ESP="Proceso finalizado"';
        UserIsDeactivatedErrLbl: Label 'The user is deactivated. Reactivate the user before assigning roles.', Comment = 'ESP="El usuario está dado de baja. Reactívelo antes de asignar roles"';
        UserDeactivatedMsgLbl: Label 'User %1 has been deactivated and role assignments were moved to history.', Comment = 'ESP="El usuario %1 se ha dado de baja y las asignaciones de rol se han movido a histórico"';
        UserReactivatedMsgLbl: Label 'User %1 has been reactivated and role assignments were restored.', Comment = 'ESP="El usuario %1 se ha reactivado y se han restaurado las asignaciones de rol"';
        WelcomeEmailSentMsgLbl: Label 'Welcome email sent to %1.', Comment = 'ESP="Correo de bienvenida enviado a %1."';
        WipConfigurationPendingMsgLbl: Label 'WIP configuration action is pending migration from legacy NAV process.', Comment = 'ESP="La acción de configuración de obra gasto en curso está pendiente de migración desde el proceso legacy de NAV"';
}

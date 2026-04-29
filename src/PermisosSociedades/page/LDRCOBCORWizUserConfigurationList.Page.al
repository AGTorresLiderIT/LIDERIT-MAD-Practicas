page 50027 COBCORWizUserConfigurationList
{
    ApplicationArea = All;
    Caption = 'Wizard User List', Comment = 'ESP="Wizard Lista Usuarios"';
    PageType = List;
    SourceTable = COBCORWizUserConfigurationList;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(COBCORUserID; Rec.COBCORUserID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field.', Comment = 'ESP="ID Usuario"';
                    Style = Unfavorable;
                    StyleExpr = ShowInactiveStyle;
                }
                field(COBCORFullName; Rec.COBCORFullName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Especifica el nombre completo del usuario.', Comment = 'ESP="Nombre completo"';
                    Style = Unfavorable;
                    StyleExpr = ShowInactiveStyle;
                }
                field(COBCOREmail; Rec.COBCOREmail)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Email field.', Comment = 'ESP="Correo Electronico"';
                    Style = Unfavorable;
                    StyleExpr = ShowInactiveStyle;
                }
                field(COBCORDepartment; Rec.COBCORDepartment)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Department field.', Comment = 'ESP="Departamento"';
                    Style = Unfavorable;
                    StyleExpr = ShowInactiveStyle;
                }
                field(COBCORCountryName; Rec.COBCORCountryName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country Name field.', Comment = 'ESP="Nombre Pais"';
                }
                field(COBCORRegistrationDate; Rec.COBCORRegistrationDate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Registration Date field.', Comment = 'ESP="Fecha de Alta"';
                    Style = Unfavorable;
                    StyleExpr = ShowInactiveStyle;
                }
                field(COBCORConnection; Rec.COBCORConnection)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Connection field.', Comment = 'ESP="Conexion"';
                    Style = Unfavorable;
                    StyleExpr = ShowInactiveStyle;
                }
                field(COBCORBusinessGroup; Rec.COBCORBusinessGroup)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Business Group field.', Comment = 'ESP="Grupo Empresarial"';
                    Style = Unfavorable;
                    StyleExpr = ShowInactiveStyle;

                }
                field(COBCORLicenseType; Rec.COBCORLicenseType)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the License Type field.', Comment = 'ESP="Tipo de Licencias"';
                }
                field(COBCORMenu; Rec.COBCORMenu)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User Menu field.', Comment = 'ESP="Menu"';
                    Style = Unfavorable;
                    StyleExpr = ShowInactiveStyle;
                }
                field(COBCORLanguage; Rec.COBCORLanguage)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language field.', Comment = 'ESP="Idioma"';
                }
                field(COBCORResponsible; Rec.COBCORResponsible)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Responsible field.', Comment = 'ESP="Responsable"';
                    Style = Unfavorable;
                    StyleExpr = ShowInactiveStyle;
                }
                field(COBCORUnderReview; Rec.COBCORUnderReview)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the user is under review.', Comment = 'ESP="En Revision"';
                }
                field(COBCORDeactivated; Rec.COBCORDeactivated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the user is deactivated.', Comment = 'ESP="Dado de Baja"';
                }
                field(COBCORDeactivationDate; Rec.COBCORDeactivationDate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deactivation Date field.', Comment = 'ESP="Fecha de Baja"';
                }
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

                actionref(COBCORUserRegistrationRef; UserRegistration)
                {
                }
                actionref(COBCORCompanyRolesRef; CompanyRoles)
                {
                }
                actionref(COBCORUserConfigurationRef; UserConfiguration)
                {
                }
                actionref(COBCORWizardSetupRef; COBCORWizardSetup)
                {
                }
            }
        }
        area(Processing)
        {
            group(ActionsGroup)
            {
                Caption = 'Actions', Comment = 'ESP="Acciones"';
                Visible = ShowActions;

                action(FindUserByCountriesReport)
                {
                    ApplicationArea = All;
                    Caption = 'Find User by countries', Comment = 'ESP="Búsqueda usuarios x paises"';
                    Image = Approval;
                    ToolTip = 'Runs the find User by countries report.', Comment = 'ESP="Ejecuta el informe Búsqueda usuarios x paises"';

                    trigger OnAction()
                    begin
                    end;
                }

                action(GenerateEmailList)
                {
                    ApplicationArea = All;
                    Caption = 'Generate Email List', Comment = 'ESP="Generar Lista Correos"';
                    Image = List;
                    ToolTip = 'Runs the email list generation report.', Comment = 'ESP="Ejecuta el informe para generar la lista de correos"';
                    Enabled = false;

                    trigger OnAction()
                    begin
                        Report.Run(79403, true, false);
                    end;
                }
                action(AuditReport)
                {
                    ApplicationArea = All;
                    Caption = 'Audit Report', Comment = 'ESP="Informe Auditoria"';
                    Image = Report;
                    ToolTip = 'Runs the audit report.', Comment = 'ESP="Ejecuta el informe de auditoría"';
                    Enabled = false;

                    trigger OnAction()
                    begin
                        Report.Run(79724, true, false);
                    end;
                }
                action(MassiveDeactivationFromExcel)
                {
                    ApplicationArea = All;
                    Caption = 'Massive Deactivation from Excel', Comment = 'ESP="Bajas Masivas desde Excel"';
                    Image = Import;
                    ToolTip = 'Runs the massive deactivation process from Excel.', Comment = 'ESP="Ejecuta el proceso de bajas masivas desde Excel"';
                    Enabled = false;

                    trigger OnAction()
                    begin
                        Report.Run(79630, true, false);
                    end;
                }
                action(SendWelcomeEmail)
                {
                    ApplicationArea = All;
                    Caption = 'Send Welcome Email', Comment = 'ESP="Enviar correo de Bienvenida"';
                    Image = Info;
                    ToolTip = 'Sends a welcome email in the user language with the configured manual attached.', Comment = 'ESP="Envía un correo de bienvenida en el idioma del usuario con el manual configurado adjunto."';

                    trigger OnAction()
                    begin
                        gCOBCORWizUsersMgt.SendWelcomeEmail(Rec);
                        Message(WelcomeEmailSentMsgLbl, Rec.COBCOREmail);
                    end;
                }
            }
            action(CompanyRoles)
            {
                ApplicationArea = All;
                Caption = 'Company - Roles', Comment = 'ESP="Empresa - Roles"';
                Image = Company;
                ToolTip = 'Opens company-role configuration for the selected user.', Comment = 'ESP="Abre la configuración empresa-roles del usuario seleccionado"';

                trigger OnAction()
                var
                    UserConfiguration: Record COBCORWizUserConfigurationList;
                begin
                    UserConfiguration.SetRange(COBCORUserID, Rec.COBCORUserID);
                    if UserConfiguration.FindFirst() then
                        Page.RunModal(Page::COBCORWizAssignRoles, UserConfiguration);
                end;
            }
            action(UserConfiguration)
            {
                ApplicationArea = All;
                Caption = 'User Configuration', Comment = 'ESP="Configuracion Usuario"';
                Image = Setup;
                ToolTip = 'Opens user local configuration for the selected user.', Comment = 'ESP="Abre la configuración local del usuario seleccionado"';

                trigger OnAction()
                var
                    UserConfigData: Record COBCORWizUserConfigurationData;
                    TempUserConfigData: Record COBCORWizUserConfigurationData temporary;
                begin
                    if gCOBCORWizUsersMgt.IsSupportDepartment(Rec.COBCORDepartment) then
                        gCOBCORWizUsersMgt.InsertSupportCompanies(Rec.COBCORUserID);

                    UserConfigData.Reset();
                    UserConfigData.SetRange(COBCORUserID, Rec.COBCORUserID);
                    UserConfigData.SetRange(COBCORCompanyRole, gCOBCORWizUsersMgt.GetNubeAllPermission());

                    if UserConfigData.FindSet() then
                        repeat
                            TempUserConfigData := UserConfigData;
                            if TempUserConfigData.Insert() then;
                        until UserConfigData.Next() = 0;

                    if not TempUserConfigData.IsEmpty() then
                        Page.RunModal(Page::COBCORPermisosCore, TempUserConfigData)
                    else
                        Message('No specific configuration found for this user.');
                end;
            }
            action(UserRegistration)
            {
                ApplicationArea = All;
                Caption = 'User Registration', Comment = 'ESP="Alta de Usuario"';
                Image = Create;
                ToolTip = 'Opens user registration.', Comment = 'ESP="Abre el alta de usuario"';

                trigger OnAction()
                begin
                    Page.RunModal(Page::COBCORWizUserRegistration);
                end;
            }
            action(COBCORWizardSetup)
            {
                ApplicationArea = All;
                Visible = ShowActions;
                Caption = 'Wizard Setup', Comment = 'ESP="Configuración Wizard"';
                Image = Setup;
                ToolTip = 'Opens the Wizard configuration page.', Comment = 'ESP="Abre la página de configuración del Wizard"';

                trigger OnAction()
                begin
                    Page.Run(Page::COBCORWizSetup);
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        Permisos: Codeunit LDRCOBCORPermisosMgt;
        ContraseñaPage: Page "Contraseña";
    begin
        if "ContraseñaPage".RunModal() <> Action::OK then
            Error('Acceso cancelado.');
        Permisos.CheckIsCoreAdmin();
        ShowActions := true;
        g_recUserSetup.get(UserId);
        FilterUsersByCountry();
        Rec.SetRange(COBCORDeactivated, false);
    end;

    trigger OnAfterGetRecord()
    begin
        ShowInactiveStyle := Rec.COBCORDeactivated;
    end;

    procedure SetRegistroUsuarios(var UserRecords: Record COBCORWizUserConfigurationList) SelectionFilter: Text[250]
    begin
        CurrPage.SetSelectionFilter(UserRecords);
        UserRecords.SetCurrentKey(COBCORUserID);

        if UserRecords.Count > 0 then begin
            UserRecords.FindFirst();
            SelectionFilter := UserRecords.COBCORFullName;
        end;
    end;

    local procedure FilterUsersByCountry()
    var
    begin
    end;

    var
        gCOBCORWizUsersMgt: Codeunit COBCORWizUsersMgt;
        g_recUserSetup: Record "User Setup";
        ShowActions: Boolean;
        ShowInactiveStyle: Boolean;
        WelcomeEmailSentMsgLbl: Label 'Welcome email sent to %1.', Comment = 'ESP="Correo de bienvenida enviado a %1."';
}

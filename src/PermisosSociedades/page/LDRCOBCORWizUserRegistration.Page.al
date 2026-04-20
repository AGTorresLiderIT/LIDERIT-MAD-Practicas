page 50028 COBCORWizUserRegistration
{
    ApplicationArea = All;
    Caption = 'Wizard User Registration', Comment = 'ESP="Wizard Alta de Usuario"';
    PageType = Card;
    SourceTable = COBCORWizUserConfigurationList;
    SourceTableTemporary = true;
    UsageCategory = None;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(COBCORGeneral)
            {
                Caption = 'General', Comment = 'ESP="General"';

                field(COBCORConnection; gCOBCORConnection)
                {
                    ApplicationArea = All;
                    Caption = 'Connection Type', Comment = 'ESP="Tipo de Conexion"';
                    ToolTip = 'Specifies the connection type used to register the user.', Comment = 'ESP="Especifica el tipo de conexión usado para registrar el usuario"';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        gCOBCORWizUsersMgt.UpdateVisibilityByConnection(
                          gCOBCORConnection,
                          gCOBCORShowConnectionWarning,
                          gCOBCORShowBusinessCentralUserID,
                          gCOBCORShowLicenseType,
                          gCOBCOROtherDbUserID,
                          gCOBCORBusinessGroup,
                          gCOBCORFullName,
                          gCOBCORLicenseType);
                        CurrPage.Update(false);
                    end;
                }
                field(COBCORBusinessGroup; gCOBCORBusinessGroup)
                {
                    ApplicationArea = All;
                    Caption = 'Business Group', Comment = 'ESP="Grupo Empresarial"';
                    ToolTip = 'Specifies the business group for the user registration.', Comment = 'ESP="Especifica el grupo empresarial para el alta del usuario"';
                    ShowMandatory = true;

                }
                group(COBCORConnectionWarningGroup)
                {
                    ShowCaption = false;
                    Visible = gCOBCORShowConnectionWarning;

                    field(COBCORConnectionWarning; gCOBCORConnectionWarning)
                    {
                        ApplicationArea = All;
                        Caption = 'Connection Warning', Comment = 'ESP="Aviso de conexión"';
                        Editable = false;
                        Style = Attention;
                        StyleExpr = true;
                        ToolTip = 'Displays a warning when no connection type has been selected.', Comment = 'ESP="Muestra un aviso cuando no se ha seleccionado tipo de conexión"';
                    }
                }
                group(COBCORBusinessCentralUserIDGroup)
                {
                    ShowCaption = false;
                    Visible = gCOBCORShowBusinessCentralUserID;

                    field(COBCORBusinessCentralUserID; gCOBCORBusinessCentralUserID)
                    {
                        ApplicationArea = All;
                        Caption = 'User ID', Comment = 'ESP="ID Usuario"';
                        ToolTip = 'Specifies the user ID for Business Central.', Comment = 'ESP="Especifica el ID de usuario para Business Central"';

                        trigger OnValidate()
                        var
                            lUser: Record User;
                        begin
                            if gCOBCORBusinessCentralUserID = '' then begin
                                gCOBCORFullName := '';
                                gCOBCORLicenseType := gCOBCORLicenseType::Blank;
                                exit;
                            end;

                            lUser.Reset();
                            lUser.SetRange("User Name", gCOBCORBusinessCentralUserID);
                            if lUser.FindFirst() then
                                gCOBCORWizUsersMgt.LoadBusinessCentralUserData(lUser, gCOBCORFullName, gCOBCOREmail, gCOBCORLicenseType)
                            else begin
                                gCOBCORFullName := '';
                                gCOBCORLicenseType := gCOBCORLicenseType::Blank;
                            end;
                        end;

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            lUser: Record User;
                            lUsers: Page Users;
                        begin
                            lUsers.LookupMode(true);
                            if lUsers.RunModal() = Action::LookupOK then begin
                                lUsers.GetRecord(lUser);
                                gCOBCORBusinessCentralUserID := lUser."User Name";
                                Text := gCOBCORBusinessCentralUserID;
                                gCOBCORWizUsersMgt.LoadBusinessCentralUserData(lUser, gCOBCORFullName, gCOBCOREmail, gCOBCORLicenseType);
                            end;

                            exit(true);
                        end;
                    }
                    field(COBCORFullName; gCOBCORFullName)
                    {
                        ApplicationArea = All;
                        Caption = 'Full Name', Comment = 'ESP="Nombre completo"';
                        ToolTip = 'Especifica el nombre completo del usuario.', Comment = 'ESP="Especifica el nombre completo del usuario"';
                        Editable = true;
                        ShowMandatory = true;
                    }
                }
                field(COBCORCountry; gCOBCORCountry)
                {
                    ApplicationArea = All;
                    Caption = 'Country', Comment = 'ESP="País"';
                    TableRelation = "Country/Region".Code;
                    ToolTip = 'Specifies the country code of the user.', Comment = 'ESP="Especifica el código de país del usuario"';
                    ShowMandatory = true;
                }
                field(COBCORResponsiblePermission; gCOBCORResponsiblePermission)
                {
                    ApplicationArea = All;
                    Caption = 'Delegation Responsible', Comment = 'ESP="Responsable Delegación"';
                    ToolTip = 'Specifies the delegation responsible for the registration.', Comment = 'ESP="Especifica el responsable de delegación para el alta"';
                }
                field(COBCOREmail; gCOBCOREmail)
                {
                    ApplicationArea = All;
                    Caption = 'Email', Comment = 'ESP="Correo Electronico"';
                    ToolTip = 'Specifies the user email.', Comment = 'ESP="Especifica el correo electrónico del usuario"';
                    ShowMandatory = true;

                    trigger OnValidate()
                    var
                        lAtPos: Integer;
                    begin
                        lAtPos := StrPos(gCOBCOREmail, '@');
                        if lAtPos > 1 then
                            gCOBCOROtherDbUserID := 'GCOBRA\\' + CopyStr(gCOBCOREmail, 1, lAtPos - 1);
                    end;
                }
                field(COBCORDepartment; gCOBCORDepartment)
                {
                    ApplicationArea = All;
                    Caption = 'Department', Comment = 'ESP="Departamento"';
                    TableRelation = COBCORWizDepartment.COBCORCode;
                    ToolTip = 'Specifies the user department.', Comment = 'ESP="Especifica el departamento del usuario"';
                    ShowMandatory = true;
                }
                field(COBCORLanguage; gCOBCORLanguage)
                {
                    ApplicationArea = All;
                    Caption = 'Language', Comment = 'ESP="Idioma"';
                    ToolTip = 'Specifies the language for the user.', Comment = 'ESP="Especifica el idioma del usuario"';
                }
                group(COBCORLicenseGroup)
                {
                    Caption = 'License', Comment = 'ESP="Licencia"';
                    Visible = gCOBCORShowLicenseType;

                    field(COBCORLicenseType; gCOBCORLicenseType)
                    {
                        ApplicationArea = All;
                        Caption = 'License Type', Comment = 'ESP="Tipo de Licencia"';
                        ToolTip = 'Specifies the license type for Business Central users.', Comment = 'ESP="Especifica el tipo de licencia para usuarios de Business Central"';
                    }
                }
            }

            group(COBCORRegistrationData)
            {
                Caption = 'Registration Data', Comment = 'ESP="Datos de Alta"';

                field(COBCOREasyVistaRegistration; gCOBCOREasyVistaRegistration)
                {
                    ApplicationArea = All;
                    Caption = 'EasyVista Registration', Comment = 'ESP="EasyVista Alta"';
                    ToolTip = 'Specifies the EasyVista registration code.', Comment = 'ESP="Especifica el código de alta de EasyVista"';

                    trigger OnValidate()
                    begin
                        if gCOBCOREasyVistaRegistration <> '' then begin
                            gCOBCORRegistrationDate := Today;
                            gCOBCORRegistrationResponsible := UserId;
                        end;
                    end;
                }
                field(COBCORRegistrationDate; gCOBCORRegistrationDate)
                {
                    ApplicationArea = All;
                    Caption = 'Registration Date', Comment = 'ESP="Fecha de Alta"';
                    Editable = false;
                    ToolTip = 'Specifies the registration date.', Comment = 'ESP="Especifica la fecha de alta"';
                }
                field(COBCORRegistrationResponsible; gCOBCORRegistrationResponsible)
                {
                    ApplicationArea = All;
                    Caption = 'Registration Responsible', Comment = 'ESP="Responsable Alta"';
                    Editable = false;
                    ToolTip = 'Specifies the responsible user for the registration.', Comment = 'ESP="Especifica el usuario responsable del alta"';
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

                actionref(COBCORRegisterRef; COBCORRegister)
                {
                }
                actionref(COBCORClearRef; COBCORClear)
                {
                }
                actionref(COBCORNextRef; COBCORNext)
                {
                }
            }
        }

        area(Processing)
        {
            action(COBCORRegister)
            {
                ApplicationArea = All;
                Caption = 'Register', Comment = 'ESP="Registrar"';
                Image = Create;
                ToolTip = 'Registers the user with the entered data.', Comment = 'ESP="Registra el usuario con los datos introducidos"';

                trigger OnAction()
                var
                    lUserID: Text[140];
                begin
                    lUserID := gCOBCORWizUsersMgt.GetSelectedUserIdByConnection(gCOBCORConnection, gCOBCORWindowsUserID, gCOBCORDatabaseUserID, gCOBCOROtherDbUserID, gCOBCORBusinessCentralUserID);
                    gCOBCORWizUsersMgt.ValidateMandatoryRegistrationData(gCOBCORConnection, gCOBCORBusinessGroup, gCOBCORFullName, gCOBCORCountry, gCOBCOREmail, gCOBCORDepartment, gCOBCOREasyVistaRegistration, lUserID, gCOBCORLicenseType);
                    gCOBCORWizUsersMgt.RegisterOrUpdateUser(lUserID, gCOBCORFullName, gCOBCORCountry, gCOBCORResponsiblePermission, gCOBCOREmail, gCOBCORDepartment, gCOBCORLanguage, gCOBCORConnection, gCOBCORBusinessGroup, gCOBCORLicenseType, gCOBCOREasyVistaRegistration, gCOBCORRegistrationDate);
                    Message(gCOBCORUserRegisteredMsgLbl, lUserID);
                end;
            }
            action(COBCORClear)
            {
                ApplicationArea = All;
                Caption = 'Clear', Comment = 'ESP="Limpiar"';
                Image = ClearFilter;
                ToolTip = 'Clears all entered values.', Comment = 'ESP="Limpia todos los valores introducidos"';

                trigger OnAction()
                begin
                    gCOBCORWizUsersMgt.ClearRegistrationValues(
                        gCOBCORConnection,
                        gCOBCORBusinessGroup,
                        gCOBCORWindowsUserID,
                        gCOBCORDatabaseUserID,
                        gCOBCOROtherDbUserID,
                        gCOBCORBusinessCentralUserID,
                        gCOBCORFullName,
                        gCOBCORCountry,
                        gCOBCORResponsiblePermission,
                        gCOBCOREmail,
                        gCOBCORDepartment,
                        gCOBCORLanguage,
                        gCOBCORLicenseType,
                        gCOBCOREasyVistaRegistration,
                        gCOBCORRegistrationDate,
                        gCOBCORRegistrationResponsible);
                    gCOBCORWizUsersMgt.UpdateVisibilityByConnection(
                        gCOBCORConnection,
                        gCOBCORShowConnectionWarning,
                        gCOBCORShowBusinessCentralUserID,
                        gCOBCORShowLicenseType,
                        gCOBCOROtherDbUserID,
                        gCOBCORBusinessGroup,
                        gCOBCORFullName,
                        gCOBCORLicenseType);
                    CurrPage.Update(false);
                end;
            }
            action(COBCORNext)
            {
                ApplicationArea = All;
                Caption = 'Next', Comment = 'ESP="Siguiente"';
                Image = NextRecord;
                ToolTip = 'Opens the roles assignment page for the registered user.', Comment = 'ESP="Abre la página de asignación de roles para el usuario registrado"';

                trigger OnAction()
                var
                    lUserConfiguration: Record COBCORWizUserConfigurationList;
                    lUserID: Text[140];
                begin
                    lUserID := gCOBCORWizUsersMgt.GetSelectedUserIdByConnection(gCOBCORConnection, gCOBCORWindowsUserID, gCOBCORDatabaseUserID, gCOBCOROtherDbUserID, gCOBCORBusinessCentralUserID);
                    if lUserID = '' then
                        Error(gCOBCORUserNotRegisteredErrLbl);

                    lUserConfiguration.Reset();
                    lUserConfiguration.SetRange(COBCORUserID, lUserID);
                    if not lUserConfiguration.FindFirst() then
                        Error(gCOBCORUserNotRegisteredErrLbl);

                    Page.RunModal(Page::COBCORWizAssignRoles, lUserConfiguration);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        gCOBCORConnection := gCOBCORConnection::"Business Central";
        gCOBCORLanguage := gCOBCORLanguage::Spanish;
        gCOBCORConnectionWarning := gCOBCORConnectionWarningLbl;
        gCOBCORWizUsersMgt.UpdateVisibilityByConnection(
          gCOBCORConnection,
          gCOBCORShowConnectionWarning,
          gCOBCORShowBusinessCentralUserID,
          gCOBCORShowLicenseType,
          gCOBCOROtherDbUserID,
          gCOBCORBusinessGroup,
          gCOBCORFullName,
          gCOBCORLicenseType);
    end;

    var
        gCOBCORWizUsersMgt: Codeunit COBCORWizUsersMgt;
        gCOBCORConnection: Enum COBCORWizUserConfigConnection;
        gCOBCORBusinessGroup: Code[20];
        gCOBCORDepartment: Code[30];
        gCOBCORLanguage: Enum COBCORWizUserConfigLanguage;
        gCOBCORLicenseType: Enum COBCORWizUserConfigLicenseType;
        gCOBCORWindowsUserID: Text[140];
        gCOBCORDatabaseUserID: Text[140];
        gCOBCOROtherDbUserID: Text[140];
        gCOBCORBusinessCentralUserID: Text[140];
        gCOBCORFullName: Text[150];
        gCOBCORCountry: Text[50];
        gCOBCORResponsiblePermission: Text[250];
        gCOBCOREmail: Text[100];
        gCOBCOREasyVistaRegistration: Code[30];
        gCOBCORRegistrationDate: Date;
        gCOBCORRegistrationResponsible: Text[250];
        gCOBCORConnectionWarning: Text[100];
        gCOBCORShowConnectionWarning: Boolean;
        gCOBCORShowBusinessCentralUserID: Boolean;
        gCOBCORShowLicenseType: Boolean;
        gCOBCORConnectionWarningLbl: Label 'You must choose the connection type.', Comment = 'ESP="Debe elegir el tipo de conexión"';
        gCOBCORUserRegisteredMsgLbl: Label 'User %1 has been registered correctly.', Comment = 'ESP="El usuario %1 se ha registrado correctamente"';
        gCOBCORUserNotRegisteredErrLbl: Label 'The user is not registered yet. Press Register first.', Comment = 'ESP="El usuario no está dado de alta todavía, pulse primero en Registrar"';
}

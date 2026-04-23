codeunit 50007 COBCORWizUsersMgt
{
    Permissions = tabledata "Tenant Permission Set" = rimd,
                  tabledata "Tenant Permission" = rimd;

    #region GESTIÓN DE ROLES DE USUARIO

    procedure MarkAllRolesForUser(pUserID: Text[140]; pDeleteValue: Boolean)
    var
        lUserConfigData: Record COBCORWizUserConfigurationData;
    begin
        lUserConfigData.Reset();
        lUserConfigData.SetRange(COBCORUserID, pUserID);
        if lUserConfigData.FindSet(true) then
            repeat
                lUserConfigData.COBCORDelete := pDeleteValue;
                lUserConfigData.Modify();
            until lUserConfigData.Next() = 0;
    end;

    procedure DeleteMarkedRolesForUser(pUserID: Text[140]): Integer
    var
        lDeletedCount: Integer;
        lUserConfigData: Record COBCORWizUserConfigurationData;
        lRemainingDelegation: Text[250];
        lDeletedRoleID: Code[20];
        lDeletedIsExtraRole: Boolean;
        lDeletedIsDerivedRole: Boolean;
    begin
        lDeletedCount := 0;

        lUserConfigData.Reset();
        lUserConfigData.SetRange(COBCORUserID, pUserID);
        lUserConfigData.SetRange(COBCORDelete, true);
        if lUserConfigData.FindSet(true) then
            repeat
                if lUserConfigData.COBCORDelegation <> '' then
                    HandleDelegationRemovalOnDelete(
                        lUserConfigData.COBCORCompanyRole,
                        lUserConfigData.COBCORDelegation,
                        lRemainingDelegation);

                lDeletedRoleID := lUserConfigData.COBCORCompanyRole;
                lDeletedIsExtraRole := lUserConfigData.COBCORIsExtraRole;
                lDeletedIsDerivedRole := lUserConfigData.COBCORIsDerivedRole;
                RemoveAccessControlByRole(pUserID, lUserConfigData.COBCORCompanyRole, lUserConfigData.COBCORCompanyName);
                lUserConfigData.Delete();
                if (not lDeletedIsExtraRole) and lDeletedIsDerivedRole then
                    DeleteDerivedTenantPermissionSetIfUnused(pUserID, lDeletedRoleID);
                lDeletedCount += 1;
            until lUserConfigData.Next() = 0;

        exit(lDeletedCount);
    end;

    procedure ResetDeleteMarksForUser(pUserID: Text[140])
    var
        lUserConfigData: Record COBCORWizUserConfigurationData;
    begin
        lUserConfigData.Reset();
        lUserConfigData.SetRange(COBCORDelete, true);
        if pUserID <> '' then
            lUserConfigData.SetRange(COBCORUserID, pUserID);

        if lUserConfigData.FindSet(true) then
            repeat
                lUserConfigData.COBCORDelete := false;
                lUserConfigData.Modify();
            until lUserConfigData.Next() = 0;
    end;

    procedure RegisterRoleForUser(pUserID: Text[140]; pCompanyName: Text[30]; pRoleID: Code[20]; pDelegation: Text[250])
    var
        lDerivedRoleID: Code[20];
        lDerivedRoleID1: Code[20];
        lDerivedRoleIDSin: Code[20];
    begin
        if (pCompanyName = '') or (pRoleID = '') then
            Error(gCompanyRoleRequiredErrLbl);

        if IsParentCompany(pCompanyName) then
            Error(gParentCompanyNotAllowedErrLbl, pCompanyName);

        AssignRoleAndAccess(pUserID, pCompanyName, pRoleID, '', false, false);

        if pDelegation <> '' then begin
            GenerateDerivedPermissionRoleIds(pUserID, pRoleID, lDerivedRoleID, lDerivedRoleID1, lDerivedRoleIDSin);
            CreateDelegationPermissionSets(pDelegation, pRoleID, lDerivedRoleID, lDerivedRoleID1);
            RegisterDerivedWizardRoles(pUserID, pCompanyName, pDelegation, lDerivedRoleID, lDerivedRoleID1);
        end else begin
            GenerateDerivedPermissionRoleIds(pUserID, pRoleID, lDerivedRoleID, lDerivedRoleID1, lDerivedRoleIDSin);
            CreatePermissionSetWithoutSecurityFilter(pRoleID, lDerivedRoleIDSin);
            AssignRoleAndAccess(pUserID, pCompanyName, lDerivedRoleIDSin, '', true, true);
        end;

        ApplyExtraRoleSetup(pUserID, pRoleID, pCompanyName, pDelegation);
    end;

    #endregion

    #region CICLO DE VIDA DE USUARIO (ACTIVACIÓN/DESACTIVACIÓN)

    procedure HandleDeactivationChange(var pUserConfiguration: Record COBCORWizUserConfigurationList; pPreviousDeactivated: Boolean)
    begin
        if pUserConfiguration.COBCORDeactivated = pPreviousDeactivated then
            exit;

        if pUserConfiguration.COBCORDeactivated then begin
            if IsCurrentSessionUser(pUserConfiguration.COBCORUserID) then
                Error(gSelfDeactivationNotAllowedErrLbl);

            ValidateNoOpenApprovals(pUserConfiguration.COBCORUserID);
            MoveRolesToHistory(pUserConfiguration.COBCORUserID);
            DeleteAllUserAccessControl(pUserConfiguration.COBCORUserID);
            pUserConfiguration.COBCORDeactivationResponsible := UserId();
        end else begin
            RestoreRolesFromHistory(pUserConfiguration.COBCORUserID);
            EnsureUserSetupExists(pUserConfiguration.COBCORUserID);
            pUserConfiguration.COBCORDeactivationResponsible := '';
        end;
    end;

    procedure LookupDelegationValue(pCompanyName: Text[30]; var pDelegationCode: Text[250]): Boolean
    var
        lSetup: Record COBCORWizSetup;
        lDimensionValue: Record "Dimension Value";
        lDimensionValuesPage: Page "Dimension Values";
        lDimensionCode: Code[20];
        lDelegationFilter: Text[250];
    begin
        if pCompanyName = '' then
            Error(gCompanyRequiredErrLbl);

        if not lSetup.Get() then
            Error(gWizardSetupRequiredErrLbl);

        lDimensionCode := lSetup.COBCORDelegationDimension;
        if lDimensionCode = '' then
            Error(gDelegationDimensionNotConfiguredErrLbl, pCompanyName);

        lDimensionValue.Reset();
        lDimensionValue.ChangeCompany(pCompanyName);
        lDimensionValue.SetRange("Dimension Code", lDimensionCode);

        lDimensionValuesPage.SetTableView(lDimensionValue);
        lDimensionValuesPage.SetRecord(lDimensionValue);

        lDimensionValuesPage.LookupMode(true);
        if lDimensionValuesPage.RunModal() <> Action::LookupOK then
            exit(false);

        lDimensionValuesPage.SetSelectionFilter(lDimensionValue);
        if lDimensionValue.FindSet() then
            repeat
                if lDelegationFilter <> '' then
                    lDelegationFilter += '|';
                lDelegationFilter += lDimensionValue.Code;
            until lDimensionValue.Next() = 0;

        if lDelegationFilter = '' then begin
            lDimensionValuesPage.GetRecord(lDimensionValue);
            lDelegationFilter := lDimensionValue.Code;
        end;

        pDelegationCode := CopyStr(lDelegationFilter, 1, MaxStrLen(pDelegationCode));
        exit(true);
    end;

    local procedure IsCurrentSessionUser(pUserID: Text[140]): Boolean
    var
        lUser: Record User;
    begin
        if UpperCase(pUserID) = UpperCase(UserId()) then
            exit(true);

        if lUser.Get(UserSecurityId()) then
            if UpperCase(pUserID) = UpperCase(lUser."User Name") then
                exit(true);

        exit(false);
    end;

    local procedure ValidateNoOpenApprovals(pUserID: Text[140])
    var
        lApprovalEntry: Record "Approval Entry";
    begin
        lApprovalEntry.Reset();
        lApprovalEntry.SetRange(Status, lApprovalEntry.Status::Open);
        lApprovalEntry.SetRange("Approver ID", pUserID);
        if not lApprovalEntry.IsEmpty() then
            Error(gUserOpenApprovalsErrLbl, pUserID);

        lApprovalEntry.Reset();
        lApprovalEntry.SetRange(Status, lApprovalEntry.Status::Open);
        lApprovalEntry.SetRange("Sender ID", pUserID);
        if not lApprovalEntry.IsEmpty() then
            Error(gUserOpenApprovalsErrLbl, pUserID);
    end;

    local procedure MoveRolesToHistory(pUserID: Text[140])
    var
        lUserConfigData: Record COBCORWizUserConfigurationData;
        lRoleHistory: Record COBCORWizUserConfigDataHist;
    begin
        lUserConfigData.Reset();
        lUserConfigData.SetRange(COBCORUserID, pUserID);
        if lUserConfigData.FindSet() then
            repeat
                lRoleHistory.Init();
                lRoleHistory.COBCORUserID := lUserConfigData.COBCORUserID;
                lRoleHistory.COBCORCompanyName := lUserConfigData.COBCORCompanyName;
                lRoleHistory.COBCORCompanyRole := lUserConfigData.COBCORCompanyRole;
                lRoleHistory.COBCORDelegation := lUserConfigData.COBCORDelegation;
                lRoleHistory.COBCORAssignedRolesSIN := lUserConfigData.COBCORAssignedRolesSIN;
                lRoleHistory.COBCORAssignedRolesFIL := lUserConfigData.COBCORAssignedRolesFIL;
                lRoleHistory.COBCORIsDerivedRole := lUserConfigData.COBCORIsDerivedRole;
                lRoleHistory.COBCORDeactivatedAt := CurrentDateTime;
                lRoleHistory.COBCORDeactivatedBy := UserId();
                lRoleHistory.Insert();
            until lUserConfigData.Next() = 0;

        lUserConfigData.Reset();
        lUserConfigData.SetRange(COBCORUserID, pUserID);
        if not lUserConfigData.IsEmpty() then
            lUserConfigData.DeleteAll(true);
    end;

    local procedure RestoreRolesFromHistory(pUserID: Text[140])
    var
        lRoleHistory: Record COBCORWizUserConfigDataHist;
    begin
        lRoleHistory.Reset();
        lRoleHistory.SetRange(COBCORUserID, pUserID);
        lRoleHistory.SetRange(COBCORReactivatedAt, 0DT);
        if lRoleHistory.FindSet(true) then
            repeat
                AssignRoleAndAccess(pUserID, lRoleHistory.COBCORCompanyName, lRoleHistory.COBCORCompanyRole, lRoleHistory.COBCORDelegation, false, lRoleHistory.COBCORIsDerivedRole);
                lRoleHistory.COBCORReactivatedAt := CurrentDateTime;
                lRoleHistory.COBCORReactivatedBy := UserId();
                lRoleHistory.Modify();
            until lRoleHistory.Next() = 0;
    end;

    #endregion

    #region CONFIGURACIÓN Y REGISTRO DE USUARIOS

    procedure InsertSupportCompanies(pUserID: Text[140])
    var
        lUserConfigData: Record COBCORWizUserConfigurationData;
        lNubeAllPerm: Code[20];
        lCompanies: List of [Text[30]];
        lCompanyName: Text[30];
    begin
        lNubeAllPerm := GetNubeAllPermission();
        lCompanies := GetConfiguredReplicationCompanies();
        foreach lCompanyName in lCompanies do begin
            if not lUserConfigData.Get(pUserID, lCompanyName, lNubeAllPerm) then begin
                lUserConfigData.Init();
                lUserConfigData.COBCORUserID := pUserID;
                lUserConfigData.COBCORCompanyName := lCompanyName;
                lUserConfigData.COBCORCompanyRole := lNubeAllPerm;
                lUserConfigData.COBCORGrantedByUser := UserId();
                lUserConfigData.COBCORGrantedDate := Today;
                lUserConfigData.COBCORGrantedTime := Time;
                lUserConfigData.Insert();
            end;
        end;
        COMMIT;
    end;

    procedure COBCOR_ExecuteCopy
    (
        par_txtUsuarioDesde: Text[50];
        par_txtUsuarioHasta: Text[140];
        par_txtSociedad: Text)
    var
        l_recConfUsuList: Record COBCORWizUserConfigurationList;
        l_recConfUsuList2: Record COBCORWizUserConfigurationList;
        l_recConfUsu: Record COBCORWizUserConfigurationData;
        lSetup: Record COBCORWizSetup;
    begin
        if par_txtUsuarioDesde = '' then
            Error('Debe indicar el usuario origen');

        if par_txtUsuarioHasta = '' then
            Error('Debe indicar el usuario destino');

        if not l_recConfUsuList.Get(par_txtUsuarioDesde) then
            Error('No se encuentra el usuario %1', par_txtUsuarioDesde);

        if not l_recConfUsuList2.Get(par_txtUsuarioHasta) then
            Error('No se encuentra el usuario %1', par_txtUsuarioHasta);

        l_recConfUsu.Reset();
        l_recConfUsu.SetRange(COBCORUserID, par_txtUsuarioDesde);

        if not lSetup.FindFirst() then
            exit;
        if par_txtSociedad <> '' then
            l_recConfUsu.SetFilter(COBCORCompanyName, '%1', par_txtSociedad);

        l_recConfUsu.SetRange(COBCORIsExtraRole, false);
        if l_recConfUsu.FindSet() then
            repeat
                //AssignRoleAndAccess(par_txtUsuarioHasta, l_recConfUsu.COBCORCompanyName, l_recConfUsu.COBCORCompanyRole, l_recConfUsu.COBCORDelegation, l_recConfUsu.COBCORIsExtraRole);
                RegisterRoleForUser(par_txtUsuarioHasta, l_recConfUsu.COBCORCompanyName, l_recConfUsu.COBCORCompanyRole, l_recConfUsu.COBCORDelegation);
            until l_recConfUsu.Next() = 0
        else
            Error('El usuario %1 no tiene configuración', par_txtUsuarioDesde);
    end;

    procedure GetNubeAllPermission(): Code[20]
    var
        lSetup: Record COBCORWizSetup;
    begin
        lSetup.Get();
        exit(lSetup.COBCORNubeAllPermission);
    end;

    procedure ValidateMandatoryRegistrationData(
        pConnection: Enum COBCORWizUserConfigConnection;
                         pBusinessGroup: Code[20];
                         pFullName: Text[150];
                         pCountry: Text[50];
                         pEmail: Text[100];
                         pDepartment: Code[30];
                         pEasyVistaRegistration: Code[30];
                         pSelectedUserID: Text[140];
                         pLicenseType: Enum COBCORWizUserConfigLicenseType)
    var
        lDepartment: Record COBCORWizDepartment;
    begin
        if pEasyVistaRegistration = '' then
            Error(gEasyVistaRequiredErrLbl);

        if (pConnection = pConnection::"Business Central") and (pLicenseType = pLicenseType::Blank) then
            Error(gLicenseTypeRequiredErrLbl);

        if (pConnection = pConnection::Blank) or
           (pBusinessGroup = '') or
           (pFullName = '') or
           (pCountry = '') or
           (pEmail = '') or
           (pDepartment = '')
        then
            Error(gMandatoryFieldsErrLbl);
        if not lDepartment.Get(pDepartment) then
            Error(gDepartmentNotFoundErrLbl, pDepartment);

        if pSelectedUserID = '' then
            Error(gUserIdRequiredErrLbl);
    end;

    procedure RegisterOrUpdateUser(
        pUserID: Text[140];
        pFullName: Text[150];
        pCountry: Text[50];
        pResponsible: Text[250];
        pEmail: Text[100];
        pDepartment: Code[30];
        pLanguage: Enum COBCORWizUserConfigLanguage;
                       pConnection: Enum COBCORWizUserConfigConnection;
                       pBusinessGroup: Code[20];
                       pLicenseType: Enum COBCORWizUserConfigLicenseType;
                       pEasyVistaRegistration: Code[30];
                       pRegistrationDate: Date)
    var
        lUserConfiguration: Record COBCORWizUserConfigurationList;
    begin
        if lUserConfiguration.Get(pUserID) then begin
            lUserConfiguration.COBCORFullName := pFullName;
            lUserConfiguration.COBCORCountry := pCountry;
            lUserConfiguration.COBCORResponsible := pResponsible;
            lUserConfiguration.COBCOREmail := pEmail;
            lUserConfiguration.COBCORDepartment := pDepartment;
            lUserConfiguration.COBCORLanguage := pLanguage;
            lUserConfiguration.COBCORConnection := pConnection;
            lUserConfiguration.COBCORBusinessGroup := pBusinessGroup;
            lUserConfiguration.COBCORLicenseType := pLicenseType;
            lUserConfiguration.COBCOREasyVistaRegistration := pEasyVistaRegistration;
            lUserConfiguration.COBCORRegistrationDate := pRegistrationDate;
            lUserConfiguration.Modify(true);
        end else begin
            lUserConfiguration.Init();
            lUserConfiguration.COBCORUserID := pUserID;
            lUserConfiguration.COBCORFullName := pFullName;
            lUserConfiguration.COBCORCountry := pCountry;
            lUserConfiguration.COBCORResponsible := pResponsible;
            lUserConfiguration.COBCOREmail := pEmail;
            lUserConfiguration.COBCORDepartment := pDepartment;
            lUserConfiguration.COBCORLanguage := pLanguage;
            lUserConfiguration.COBCORConnection := pConnection;
            lUserConfiguration.COBCORBusinessGroup := pBusinessGroup;
            lUserConfiguration.COBCORLicenseType := pLicenseType;
            lUserConfiguration.COBCOREasyVistaRegistration := pEasyVistaRegistration;
            lUserConfiguration.COBCORRegistrationDate := pRegistrationDate;
            lUserConfiguration.Insert(true);
        end;
    end;

    procedure GetSelectedUserIdByConnection(
        pConnection: Enum COBCORWizUserConfigConnection;
                         pWindowsUserID: Text[140];
                         pDatabaseUserID: Text[140];
                         pOtherDbUserID: Text[140];
                         pBusinessCentralUserID: Text[140]): Text[140]
    begin
        case pConnection of
            pConnection::"Business Central":
                exit(pBusinessCentralUserID);
        end;

        exit('');
    end;

    procedure UpdateVisibilityByConnection(
        pConnection: Enum COBCORWizUserConfigConnection;
        var pShowConnectionWarning: Boolean;
        var pShowBusinessCentralUserID: Boolean;
        var pShowLicenseType: Boolean;
        var pOtherDbUserID: Text[140];
        var pBusinessGroup: Code[20];
        var pBusinessCentralFullName: Text[100];
        var pLicenseType: Enum COBCORWizUserConfigLicenseType)
    begin
        pShowConnectionWarning := pConnection = pConnection::Blank;
        pShowBusinessCentralUserID := pConnection = pConnection::"Business Central";
        pShowLicenseType := pShowBusinessCentralUserID;

        if pShowBusinessCentralUserID then
            SetDefaultBusinessCentralGroup(pBusinessGroup);

        if not pShowBusinessCentralUserID then begin
            pBusinessCentralFullName := '';
            pLicenseType := pLicenseType::Blank;
        end;
    end;

    procedure ClearRegistrationValues(
        var pConnection: Enum COBCORWizUserConfigConnection;
        var pBusinessGroup: Code[20];
        var pWindowsUserID: Text[140];
        var pDatabaseUserID: Text[140];
        var pOtherDbUserID: Text[140];
        var pBusinessCentralUserID: Text[140];
        var pFullName: Text[150];
        var pCountry: Text[50];
        var pResponsiblePermission: Text[250];
        var pEmail: Text[100];
        var pDepartment: Code[30];
        var pLanguage: Enum COBCORWizUserConfigLanguage;
        var pLicenseType: Enum COBCORWizUserConfigLicenseType;
        var pEasyVistaRegistration: Code[30];
        var pRegistrationDate: Date;
        var pRegistrationResponsible: Text[250])
    begin
        pConnection := pConnection::Blank;
        pBusinessGroup := '';
        pWindowsUserID := '';
        pDatabaseUserID := '';
        pOtherDbUserID := '';
        pBusinessCentralUserID := '';
        pFullName := '';
        pCountry := '';
        pResponsiblePermission := '';
        pEmail := '';
        pDepartment := '';
        pLanguage := pLanguage::Spanish;
        pLicenseType := pLicenseType::Blank;
        pEasyVistaRegistration := '';
        pRegistrationDate := 0D;
        pRegistrationResponsible := '';
    end;

    procedure LoadBusinessCentralUserData(var pUser: Record User; var pBusinessCentralFullName: Text[100]; var pEmail: Text[100]; var pLicenseType: Enum COBCORWizUserConfigLicenseType)
    var
        lUserSetup: Record "User Setup";
    begin
        pBusinessCentralFullName := pUser."Full Name";
        pLicenseType := pLicenseType::Blank;

        if pUser."Contact Email" <> '' then
            pEmail := pUser."Contact Email"
        else begin
            pEmail := '';
            if lUserSetup.Get(pUser."User Name") then
                pEmail := lUserSetup."E-Mail";
        end;
    end;

    procedure SendWelcomeEmail(pUserConfiguration: Record COBCORWizUserConfigurationList)
    var
        lSetup: Record COBCORWizSetup;
        lEmailMessage: Codeunit "Email Message";
        lEmail: Codeunit Email;
        lSubject: Text;
        lBody: Text;
        lAttachmentFileName: Text;
        lAttachmentInStream: InStream;
        lEmailSent: Boolean;
    begin
        if pUserConfiguration.COBCOREmail = '' then
            Error(gWelcomeEmailAddressRequiredErrLbl, pUserConfiguration.COBCORUserID);

        if not lSetup.Get() then
            Error(gWizardSetupRequiredErrLbl);

        if lSetup.COBCORWelcomeEmailUrl = '' then
            Error(gWelcomeEmailUrlRequiredErrLbl);

        if pUserConfiguration.COBCORLanguage = pUserConfiguration.COBCORLanguage::English then begin
            lSubject := gWelcomeEmailSubjectENLbl;
            lBody := StrSubstNo(gWelcomeEmailBodyENLbl, pUserConfiguration.COBCORFullName, lSetup.COBCORWelcomeEmailUrl);

            lSetup.CalcFields(COBCORWelcomeManualEN);
            if (lSetup.COBCORWelcomeManualENName = '') or (not lSetup.COBCORWelcomeManualEN.HasValue()) then
                Error(gWelcomeManualENRequiredErrLbl);

            lAttachmentFileName := lSetup.COBCORWelcomeManualENName;
            lSetup.COBCORWelcomeManualEN.CreateInStream(lAttachmentInStream);
        end else begin
            lSubject := gWelcomeEmailSubjectESLbl;
            lBody := StrSubstNo(gWelcomeEmailBodyESLbl, pUserConfiguration.COBCORFullName, lSetup.COBCORWelcomeEmailUrl);

            lSetup.CalcFields(COBCORWelcomeManualES);
            if (lSetup.COBCORWelcomeManualESName = '') or (not lSetup.COBCORWelcomeManualES.HasValue()) then
                Error(gWelcomeManualESRequiredErrLbl);

            lAttachmentFileName := lSetup.COBCORWelcomeManualESName;
            lSetup.COBCORWelcomeManualES.CreateInStream(lAttachmentInStream);
        end;

        lEmailMessage.Create(
            pUserConfiguration.COBCOREmail,
            lSubject,
            lBody,
            true);

        lEmailMessage.AddAttachment(
            lAttachmentFileName,
            'application/pdf',
            lAttachmentInStream);

        lEmailSent := lEmail.Send(lEmailMessage);

        if not lEmailSent then
            Error(gWelcomeEmailSendFailedErrLbl);
    end;

    #endregion

    #region GESTIÓN DE ACCESO Y CONTROL DE PERMISOS

    local procedure EnsureUserSetupExists(pUserID: Text[140])
    var
        lUserSetup: Record "User Setup";
    begin
        if lUserSetup.Get(pUserID) then
            exit;

        lUserSetup.Init();
        lUserSetup."User ID" := pUserID;
        lUserSetup.Insert(true);
    end;

    local procedure DeleteAllUserAccessControl(pUserID: Text[140])
    var
        lUserSecurityID: Guid;
        lAccessControl: Record "Access Control";
    begin
        if not TryGetUserSecurityId(pUserID, lUserSecurityID) then
            exit;

        lAccessControl.Reset();
        lAccessControl.SetRange("User Security ID", lUserSecurityID);
        if not lAccessControl.IsEmpty() then
            lAccessControl.DeleteAll(true);
    end;

    local procedure GrantAccessControlByRole(pUserID: Text[140]; pRoleID: Code[20]; pCompanyName: Text[30])
    var
        lAppID: Guid;
        lPermissionSetScope: Option System,Tenant;
        lUserSecurityID: Guid;
        lAccessControl: Record "Access Control";
    begin
        if (pRoleID = '') or (pCompanyName = '') then
            exit;

        if not TryGetUserSecurityId(pUserID, lUserSecurityID) then
            exit;

        GetPermissionSetMetadata(pRoleID, lPermissionSetScope, lAppID);

        lAccessControl.Reset();
        lAccessControl.SetRange(Scope, lPermissionSetScope);
        lAccessControl.SetRange("App ID", lAppID);
        lAccessControl.SetRange("User Security ID", lUserSecurityID);
        lAccessControl.SetRange("Role ID", pRoleID);
        lAccessControl.SetRange("Company Name", pCompanyName);
        if not lAccessControl.IsEmpty() then
            exit;

        lAccessControl.Init();
        lAccessControl.Validate(Scope, lPermissionSetScope);
        lAccessControl.Validate("App ID", lAppID);
        lAccessControl.Validate("User Security ID", lUserSecurityID);
        lAccessControl.Validate("Role ID", pRoleID);
        lAccessControl.Validate("Company Name", pCompanyName);
        lAccessControl.Insert(true);
    end;

    local procedure RemoveAccessControlByRole(pUserID: Text[140]; pRoleID: Code[20]; pCompanyName: Text[30])
    var
        lAppID: Guid;
        lPermissionSetScope: Option System,Tenant;
        lUserSecurityID: Guid;
        lAccessControl: Record "Access Control";
    begin
        if (pRoleID = '') or (pCompanyName = '') then
            exit;

        if not TryGetUserSecurityId(pUserID, lUserSecurityID) then
            exit;

        GetPermissionSetMetadata(pRoleID, lPermissionSetScope, lAppID);

        lAccessControl.Reset();
        lAccessControl.SetRange(Scope, lPermissionSetScope);
        lAccessControl.SetRange("App ID", lAppID);
        lAccessControl.SetRange("User Security ID", lUserSecurityID);
        lAccessControl.SetRange("Role ID", pRoleID);
        lAccessControl.SetRange("Company Name", pCompanyName);
        if not lAccessControl.IsEmpty() then
            lAccessControl.DeleteAll(true);
    end;

    local procedure GetPermissionSetMetadata(pRoleID: Code[20]; var pScope: Option System,Tenant; var pAppID: Guid)
    var
        lAggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        Clear(pAppID);

        lAggregatePermissionSet.Reset();
        lAggregatePermissionSet.SetRange("Role ID", pRoleID);
        if not lAggregatePermissionSet.FindSet() then
            exit;

        lAggregatePermissionSet.FindFirst();
        pScope := lAggregatePermissionSet.Scope;
        pAppID := lAggregatePermissionSet."App ID";

        if lAggregatePermissionSet.Next() <> 0 then
            Error(gPermissionSetNotUniqueErrLbl, pRoleID);
    end;

    local procedure TryGetUserSecurityId(pUserID: Text[140]; var pUserSecurityID: Guid): Boolean
    var
        lUser: Record User;
    begin
        Clear(pUserSecurityID);

        lUser.Reset();
        lUser.SetRange("User Name", pUserID);
        if not lUser.FindFirst() then
            exit(false);

        pUserSecurityID := lUser."User Security ID";
        exit(true);
    end;

    local procedure IsParentCompany(pCompanyName: Text[30]): Boolean
    var
        lSetup: Record COBCORWizSetup;
    begin
        //Mio
        pCompanyName := '';
        lSetup.Get();
        exit(false);
    end;

    #endregion

    #region ROLES ADICIONALES (EXTRA SETUP)

    local procedure ApplyExtraRoleSetup(pUserID: Text[140]; pBaseRoleID: Code[20]; pCompanyName: Text[30]; pDelegation: Text[250])
    var
        lRoleExtraSetup: Record COBCORWizRoleExtraSetup;
    begin
        lRoleExtraSetup.SetRange(COBCORRoleID, pBaseRoleID);
        if not lRoleExtraSetup.FindSet() then
            exit;

        repeat
            if lRoleExtraSetup.COBCORApplyInParent then
                ApplyExtraRoleSetupByScope(pUserID, lRoleExtraSetup.COBCORExtraRoleID, pCompanyName, pDelegation, true);
            if lRoleExtraSetup.COBCORApplyInChild then
                ApplyExtraRoleSetupByScope(pUserID, lRoleExtraSetup.COBCORExtraRoleID, pCompanyName, pDelegation, false);
        until lRoleExtraSetup.Next() = 0;
    end;

    local procedure ApplyExtraRoleSetupByScope(pUserID: Text[140]; pRoleID: Code[20]; pCompanyName: Text[30]; pDelegation: Text[250]; pParent: Boolean)
    var
        lSetup: Record COBCORWizSetup;
    begin
        if not lSetup.Get() then begin
            AssignRoleAndAccess(pUserID, pCompanyName, pRoleID, pDelegation, true, false);
            exit;
            pParent := true; //MioQuitar a fúturo
        end;
    end;

    local procedure AssignRoleAndAccess(pUserID: Text[140]; pCompanyName: Text[30]; pRoleID: Code[20]; pDelegation: Text[250]; pIsExtraRole: Boolean; pIsDerivedRole: Boolean)
    begin
        UpsertRoleLine(pUserID, pCompanyName, pRoleID, pDelegation, UserId(), Today, Time, pIsExtraRole, pIsDerivedRole);
        GrantAccessControlByRole(pUserID, pRoleID, pCompanyName);
    end;

    #endregion

    #region UTILIDADES Y CONFIGURACIÓN GENERAL

    procedure IsSupportDepartment(pDepartmentCode: Code[30]): Boolean
    var
        lDepartment: Record COBCORWizDepartment;
    begin
        if lDepartment.Get(pDepartmentCode) then
            exit(lDepartment.COBCORIsSupport);
        exit(false);
    end;

    local procedure RegisterDerivedWizardRoles(pUserID: Text[140]; pCompanyName: Text[30]; pDelegation: Text[250]; pDerivedRoleID: Code[20]; pDerivedRoleID1: Code[20])
    begin
        if pDerivedRoleID <> '' then
            AssignRoleAndAccess(pUserID, pCompanyName, pDerivedRoleID, pDelegation, false, true);

        if pDerivedRoleID1 <> '' then
            AssignRoleAndAccess(pUserID, pCompanyName, pDerivedRoleID1, pDelegation, false, true);
    end;

    local procedure GenerateDerivedPermissionRoleIds(pUserID: Text[140]; pTemplateRoleID: Code[20]; var pDerivedRoleID: Code[20]; var pDerivedRoleID1: Code[20]; var pDerivedRoleIDSin: Code[20])
    var

        lBaseRoleID: Code[20];
        lrecWizRolCobra: Record COBCORWizRolesCOBRAList;
        ltxtUserID: text[12];
    begin
        lrecWizRolCobra.get(pTemplateRoleID);
        ltxtUserID := CopyStr(pUserID, 1, 12);
        lBaseRoleID := CopyStr(StrSubstNo('%1%2', ltxtUserID, lrecWizRolCobra."Role abbreviation"), 1, MaxStrLen(lBaseRoleID));
        pDerivedRoleID := BuildDerivedRoleIDWithSuffix(lBaseRoleID, 'F');
        pDerivedRoleID1 := BuildDerivedRoleIDWithSuffix(lBaseRoleID, 'F1');
        pDerivedRoleIDSin := BuildDerivedRoleIDWithSuffix(lBaseRoleID, 'SIN');
    end;

    local procedure BuildDerivedRoleIDWithSuffix(pBaseRoleID: Code[20]; pSuffix: Text[10]): Code[20]
    var
        lAllowedBaseLength: Integer;
    begin
        lAllowedBaseLength := MaxStrLen(pBaseRoleID) - StrLen(pSuffix);
        if lAllowedBaseLength < 1 then
            Error(gInvalidDerivedSuffixErrLbl, pSuffix);

        exit(CopyStr(CopyStr(pBaseRoleID, 1, lAllowedBaseLength) + pSuffix, 1, MaxStrLen(pBaseRoleID)));
    end;


    local procedure HandleDelegationRemovalOnDelete(pRoleID: Code[20]; pDelegationToRemove: Text[250]; var pRemainingDelegations: Text[250]): Boolean
    var
        lTenantPermission: Record "Tenant Permission";
        lZeroGuid: Guid;
        lCurrentFilter: Text[250];
        lUpdatedFilter: Text[250];
        lCurrentDelegations: Text[250];
        lHasNonTemplateFilters: Boolean;
        lHasRemainingDelegations: Boolean;
    begin
        Clear(pRemainingDelegations);

        lTenantPermission.Reset();
        lTenantPermission.SetRange("App ID", lZeroGuid);
        lTenantPermission.SetRange("Role ID", pRoleID);
        if not lTenantPermission.FindSet(true) then
            exit(false);

        repeat
            lCurrentFilter := Format(lTenantPermission."Security Filter");
            if (lCurrentFilter <> '') and (StrPos(UpperCase(lCurrentFilter), 'FILTRODELEGACION') = 0) then begin
                lHasNonTemplateFilters := true;
                lUpdatedFilter := RemoveDelegationsFromFilter(lCurrentFilter, pDelegationToRemove);
                if lUpdatedFilter <> lCurrentFilter then begin
                    SetTenantPermissionSecurityFilter(lTenantPermission, lUpdatedFilter);
                    lTenantPermission.Modify();
                end;
            end;
        until lTenantPermission.Next() = 0;

        if not lHasNonTemplateFilters then
            exit(false);

        lTenantPermission.Reset();
        lTenantPermission.SetRange("App ID", lZeroGuid);
        lTenantPermission.SetRange("Role ID", pRoleID);
        if lTenantPermission.FindSet() then
            repeat
                lCurrentDelegations := ExtractDelegationValuesFromSecurityFilter(Format(lTenantPermission."Security Filter"));
                if lCurrentDelegations <> '' then begin
                    lHasRemainingDelegations := true;
                    pRemainingDelegations := MergePipeListValues(
                        pRemainingDelegations,
                        lCurrentDelegations);
                end;
            until lTenantPermission.Next() = 0;


        exit(lHasRemainingDelegations);
    end;

    local procedure RemoveDelegationsFromFilter(pFilterText: Text[250]; pDelegationToRemove: Text[250]): Text[250]
    var
        lResult: Text[250];
        lRemainingDelegations: Text[250];
        lCurrentDelegation: Text[250];
        lSeparatorPos: Integer;
    begin
        lResult := pFilterText;
        lRemainingDelegations := pDelegationToRemove;

        while lRemainingDelegations <> '' do begin
            lSeparatorPos := StrPos(lRemainingDelegations, '|');
            if lSeparatorPos = 0 then begin
                lCurrentDelegation := CopyStr(lRemainingDelegations, 1, MaxStrLen(lCurrentDelegation));
                lRemainingDelegations := '';
            end else begin
                lCurrentDelegation := CopyStr(lRemainingDelegations, 1, lSeparatorPos - 1);
                lRemainingDelegations := CopyStr(lRemainingDelegations, lSeparatorPos + 1);
            end;

            if lCurrentDelegation <> '' then
                lResult := RemoveSingleDelegationFromFilter(lResult, lCurrentDelegation);
        end;

        while StrPos(lResult, '||') > 0 do
            lResult := ReplaceTextValue(lResult, '||', '|');

        while StrPos(lResult, '&&') > 0 do
            lResult := ReplaceTextValue(lResult, '&&', '&');

        if lResult <> '' then
            if CopyStr(lResult, 1, 1) = '|' then
                lResult := CopyStr(lResult, 2);

        if lResult <> '' then
            if CopyStr(lResult, 1, 1) = '&' then
                lResult := CopyStr(lResult, 2);

        if lResult <> '' then
            if CopyStr(lResult, StrLen(lResult), 1) = '|' then
                lResult := CopyStr(lResult, 1, StrLen(lResult) - 1);

        if lResult <> '' then
            if CopyStr(lResult, StrLen(lResult), 1) = '&' then
                lResult := CopyStr(lResult, 1, StrLen(lResult) - 1);

        exit(lResult);
    end;

    local procedure RemoveSingleDelegationFromFilter(pFilterText: Text[250]; pDelegationCode: Text[250]): Text[250]
    var
        lResult: Text[250];
        lSetup: Record COBCORWizSetup;
        lPrefixedDelegation: Text[250];
        lFilterPrefix: Text[250];
        lFilterValues: Text[250];
        lEqualsPos: Integer;
    begin
        lResult := pFilterText;
        lEqualsPos := StrPos(lResult, '=');

        if lEqualsPos > 0 then begin
            lFilterPrefix := CopyStr(lResult, 1, lEqualsPos);
            lFilterValues := CopyStr(lResult, lEqualsPos + 1);

            lFilterValues := RemoveTokenFromPipeList(lFilterValues, pDelegationCode);

            if lSetup.Get() and (lSetup.COBCORDelegationDimension <> '') then begin
                lPrefixedDelegation := CopyStr(lSetup.COBCORDelegationDimension + pDelegationCode, 1, MaxStrLen(lPrefixedDelegation));
                lFilterValues := RemoveTokenFromPipeList(lFilterValues, lPrefixedDelegation);
            end;

            if lFilterValues = '' then
                exit('');

            exit(CopyStr(lFilterPrefix + lFilterValues, 1, MaxStrLen(lResult)));
        end;

        if (StrPos(lResult, '&') > 0) or (CopyStr(lResult, 1, 2) = '<>') then begin
            lResult := RemoveTokenFromExclusionFilter(lResult, pDelegationCode);

            if lSetup.Get() and (lSetup.COBCORDelegationDimension <> '') then begin
                lPrefixedDelegation := CopyStr(lSetup.COBCORDelegationDimension + pDelegationCode, 1, MaxStrLen(lPrefixedDelegation));
                lResult := RemoveTokenFromExclusionFilter(lResult, lPrefixedDelegation);
            end;

            exit(lResult);
        end;

        lResult := ReplaceTextValue(lResult, '|' + pDelegationCode + '|', '|');
        lResult := ReplaceTextValue(lResult, pDelegationCode + '|', '');
        lResult := ReplaceTextValue(lResult, '|' + pDelegationCode, '');
        if lResult = pDelegationCode then
            lResult := '';

        if lSetup.Get() and (lSetup.COBCORDelegationDimension <> '') then begin
            lPrefixedDelegation := CopyStr(lSetup.COBCORDelegationDimension + pDelegationCode, 1, MaxStrLen(lPrefixedDelegation));
            lResult := ReplaceTextValue(lResult, '|' + lPrefixedDelegation + '|', '|');
            lResult := ReplaceTextValue(lResult, lPrefixedDelegation + '|', '');
            lResult := ReplaceTextValue(lResult, '|' + lPrefixedDelegation, '');
            if lResult = lPrefixedDelegation then
                lResult := '';
        end;

        exit(lResult);
    end;

    local procedure RemoveTokenFromExclusionFilter(pExclusionFilter: Text[250]; pTokenToRemove: Text[250]): Text[250]
    var
        lRemainingText: Text[250];
        lCurrentToken: Text[250];
        lSeparatorPos: Integer;
        lNormalizedToken: Text[250];
        lResult: Text[250];
    begin
        if pTokenToRemove = '' then
            exit(pExclusionFilter);

        lRemainingText := pExclusionFilter;
        while lRemainingText <> '' do begin
            lSeparatorPos := StrPos(lRemainingText, '&');
            if lSeparatorPos = 0 then begin
                lCurrentToken := lRemainingText;
                lRemainingText := '';
            end else begin
                lCurrentToken := CopyStr(lRemainingText, 1, lSeparatorPos - 1);
                lRemainingText := CopyStr(lRemainingText, lSeparatorPos + 1);
            end;

            lNormalizedToken := lCurrentToken;
            if CopyStr(lNormalizedToken, 1, 2) = '<>' then
                lNormalizedToken := CopyStr(lNormalizedToken, 3);

            if (lNormalizedToken <> '') and (UpperCase(lNormalizedToken) <> UpperCase(pTokenToRemove)) then begin
                if lResult <> '' then
                    lResult += '&';
                lResult += lCurrentToken;
            end;
        end;

        exit(lResult);
    end;

    local procedure RemoveTokenFromPipeList(pPipeList: Text[250]; pTokenToRemove: Text[250]): Text[250]
    var
        lRemainingText: Text[250];
        lCurrentToken: Text[250];
        lSeparatorPos: Integer;
        lResult: Text[250];
    begin
        if pTokenToRemove = '' then
            exit(pPipeList);

        lRemainingText := pPipeList;
        while lRemainingText <> '' do begin
            lSeparatorPos := StrPos(lRemainingText, '|');
            if lSeparatorPos = 0 then begin
                lCurrentToken := lRemainingText;
                lRemainingText := '';
            end else begin
                lCurrentToken := CopyStr(lRemainingText, 1, lSeparatorPos - 1);
                lRemainingText := CopyStr(lRemainingText, lSeparatorPos + 1);
            end;

            if (lCurrentToken <> '') and (UpperCase(lCurrentToken) <> UpperCase(pTokenToRemove)) then begin
                if lResult <> '' then
                    lResult += '|';
                lResult += lCurrentToken;
            end;
        end;

        exit(lResult);
    end;

    local procedure GetRoleDelegationFilterFromTenantPermission(pRoleID: Code[20]): Text[250]
    var
        lTenantPermission: Record "Tenant Permission";
        lZeroGuid: Guid;
        lRoleDelegationFilter: Text[250];
    begin
        if pRoleID = '' then
            exit('');

        lTenantPermission.Reset();
        lTenantPermission.SetRange("App ID", lZeroGuid);
        lTenantPermission.SetRange("Role ID", pRoleID);
        if not lTenantPermission.FindSet() then
            exit('');

        repeat
            lRoleDelegationFilter := MergePipeListValues(
                lRoleDelegationFilter,
                ExtractDelegationValuesFromSecurityFilter(Format(lTenantPermission."Security Filter")));
        until lTenantPermission.Next() = 0;

        exit(lRoleDelegationFilter);
    end;

    local procedure ExtractDelegationValuesFromSecurityFilter(pSecurityFilter: Text[250]): Text[250]
    var
        lValuesText: Text[250];
        lRemainingText: Text[250];
        lCurrentToken: Text[250];
        lUpperToken: Text[250];
        lSeparatorPos: Integer;
        lEqualPos: Integer;
        lSetup: Record COBCORWizSetup;
        lDelegationDimCode: Code[20];
        lResult: Text[250];
    begin
        if pSecurityFilter = '' then
            exit('');

        lEqualPos := StrPos(pSecurityFilter, '=');
        if lEqualPos > 0 then
            lValuesText := CopyStr(pSecurityFilter, lEqualPos + 1)
        else
            lValuesText := pSecurityFilter;

        if lSetup.Get() then
            lDelegationDimCode := lSetup.COBCORDelegationDimension;

        lRemainingText := lValuesText;
        while lRemainingText <> '' do begin
            lSeparatorPos := StrPos(lRemainingText, '|');
            if (StrPos(lRemainingText, '&') > 0) and ((lSeparatorPos = 0) or (StrPos(lRemainingText, '&') < lSeparatorPos)) then
                lSeparatorPos := StrPos(lRemainingText, '&');

            if lSeparatorPos = 0 then begin
                lCurrentToken := CopyStr(lRemainingText, 1, MaxStrLen(lCurrentToken));
                lRemainingText := '';
            end else begin
                lCurrentToken := CopyStr(lRemainingText, 1, lSeparatorPos - 1);
                lRemainingText := CopyStr(lRemainingText, lSeparatorPos + 1);
            end;

            if CopyStr(lCurrentToken, 1, 2) = '<>' then
                lCurrentToken := CopyStr(lCurrentToken, 3);

            lUpperToken := UpperCase(lCurrentToken);
            if (lCurrentToken <> '') and (lDelegationDimCode <> '') then
                if CopyStr(UpperCase(lCurrentToken), 1, StrLen(lDelegationDimCode)) = UpperCase(lDelegationDimCode) then
                    lCurrentToken := CopyStr(lCurrentToken, StrLen(lDelegationDimCode) + 1);

            if lCurrentToken <> '' then
                lResult := MergePipeListValues(lResult, lCurrentToken);
        end;

        exit(lResult);
    end;

    local procedure MergePipeListValues(pBaseList: Text[250]; pListToMerge: Text[250]): Text[250]
    var
        lResult: Text[250];
        lRemainingText: Text[250];
        lCurrentToken: Text[250];
        lSeparatorPos: Integer;
    begin
        lResult := pBaseList;
        lRemainingText := pListToMerge;

        while lRemainingText <> '' do begin
            lSeparatorPos := StrPos(lRemainingText, '|');
            if lSeparatorPos = 0 then begin
                lCurrentToken := CopyStr(lRemainingText, 1, MaxStrLen(lCurrentToken));
                lRemainingText := '';
            end else begin
                lCurrentToken := CopyStr(lRemainingText, 1, lSeparatorPos - 1);
                lRemainingText := CopyStr(lRemainingText, lSeparatorPos + 1);
            end;

            if lCurrentToken <> '' then
                if not PipeListContainsToken(lResult, lCurrentToken) then begin
                    if lResult <> '' then
                        lResult += '|';

                    lResult += lCurrentToken;
                end;
        end;

        exit(lResult);
    end;

    local procedure PipeListContainsToken(pPipeList: Text[250]; pToken: Text[250]): Boolean
    var
        lRemainingText: Text[250];
        lCurrentToken: Text[250];
        lSeparatorPos: Integer;
    begin
        if (pPipeList = '') or (pToken = '') then
            exit(false);

        lRemainingText := pPipeList;
        while lRemainingText <> '' do begin
            lSeparatorPos := StrPos(lRemainingText, '|');
            if lSeparatorPos = 0 then begin
                lCurrentToken := lRemainingText;
                lRemainingText := '';
            end else begin
                lCurrentToken := CopyStr(lRemainingText, 1, lSeparatorPos - 1);
                lRemainingText := CopyStr(lRemainingText, lSeparatorPos + 1);
            end;

            if UpperCase(lCurrentToken) = UpperCase(pToken) then
                exit(true);
        end;

        exit(false);
    end;

    local procedure SetDefaultBusinessCentralGroup(var pBusinessGroup: Code[20])
    var
    begin
        pBusinessGroup := '';//mIOQuitar a fúturo
    end;

    local procedure UpsertRoleLine(pUserID: Text[140]; pCompanyName: Text[30]; pRoleID: Code[20]; pDelegation: Text[250]; pGrantedByUser: Text[50]; pGrantedDate: Date; pGrantedTime: Time; pIsExtraRole: Boolean; pIsDerivedRole: Boolean)
    var
        lUserConfigData: Record COBCORWizUserConfigurationData;
        lStoredDelegation: Text[250];
    begin
        lStoredDelegation := NormalizeDelegationForWizardRole(pDelegation, pIsDerivedRole);

        if lUserConfigData.Get(pUserID, pCompanyName, pRoleID) then begin
            if pIsDerivedRole then
                lStoredDelegation := MergePipeListValues(lUserConfigData.COBCORDelegation, lStoredDelegation);

            lUserConfigData.COBCORDelegation := lStoredDelegation;
            lUserConfigData.COBCORIsDerivedRole := pIsDerivedRole;
            lUserConfigData.COBCORGrantedByUser := pGrantedByUser;
            lUserConfigData.COBCORGrantedDate := pGrantedDate;
            lUserConfigData.COBCORGrantedTime := pGrantedTime;
            lUserConfigData.Modify();
            EnsureUserSetupInMasterCompany(pUserID, pCompanyName);
            exit;
        end;

        lUserConfigData.Init();
        lUserConfigData.COBCORUserID := pUserID;
        lUserConfigData.COBCORCompanyName := pCompanyName;
        lUserConfigData.COBCORCompanyRole := pRoleID;
        lUserConfigData.COBCORDelegation := lStoredDelegation;
        lUserConfigData.COBCORGrantedByUser := pGrantedByUser;
        lUserConfigData.COBCORGrantedDate := pGrantedDate;
        lUserConfigData.COBCORGrantedTime := pGrantedTime;
        lUserConfigData.COBCORIsExtraRole := pIsExtraRole;
        lUserConfigData.COBCORIsDerivedRole := pIsDerivedRole;
        lUserConfigData.Insert();
        EnsureUserSetupInMasterCompany(pUserID, pCompanyName);
    end;

    local procedure NormalizeDelegationForWizardRole(pDelegation: Text[250]; pIsDerivedRole: Boolean): Text[250]
    begin
        if pIsDerivedRole then
            exit(pDelegation);

        exit('');
    end;

    local procedure DeleteDerivedTenantPermissionSetIfUnused(pUserID: Text[140]; pRoleID: Code[20])
    var
        lUserConfigData: Record COBCORWizUserConfigurationData;
    begin
        if pRoleID = '' then
            exit;

        lUserConfigData.Reset();
        lUserConfigData.SetRange(COBCORUserID, pUserID);
        lUserConfigData.SetRange(COBCORCompanyRole, pRoleID);
        lUserConfigData.SetRange(COBCORIsDerivedRole, true);
        lUserConfigData.SetRange(COBCORIsExtraRole, false);
        if lUserConfigData.IsEmpty() then
            DeleteTenantPermissionSet(pRoleID);
    end;

    local procedure EnsureUserSetupInMasterCompany(pUserID: Text[140]; pCompanyName: Text[30])
    var
        lMasterCompanyName: Text[30];
    begin
        lMasterCompanyName := /*Quitar esto -->*/pCompanyName;
        if lMasterCompanyName = '' then
            exit;

        EnsureUserSetupExistsInCompany(pUserID, lMasterCompanyName);
    end;

    local procedure EnsureUserSetupExistsInCompany(pUserID: Text[140]; pCompanyName: Text[30])
    var
        lUserSetup: Record "User Setup";
    begin
        if pCompanyName = '' then
            exit;
        lUserSetup.ChangeCompany(pCompanyName);

        if not lUserSetup.Get(pUserID) then begin
            lUserSetup.Init();
            lUserSetup."User ID" := pUserID;
            if lUserSetup.Insert(false) then;
        end;
    end;

    local procedure GetConfiguredReplicationCompanies(): List of [Text[30]]
    var
        lSetup: Record COBCORWizSetup;
        lCompanies: List of [Text[30]];
    begin
        if not lSetup.Get() then
            exit(lCompanies);
    end;

    #endregion

    #region CREACIÓN DE PERMISSION SETS DESDE PLANTILLAS

    local procedure EnsureTenantPermissionSetExists(pRoleID: Code[20])
    var
        lTenantPermissionSet: Record "Tenant Permission Set";
        lZeroGuid: Guid;
    begin
        if lTenantPermissionSet.Get(lZeroGuid, pRoleID) then begin
            if lTenantPermissionSet.Name <> pRoleID then begin
                lTenantPermissionSet.Name := pRoleID;
                lTenantPermissionSet.Modify();
            end;
            exit;
        end;

        lTenantPermissionSet.Init();
        lTenantPermissionSet."App ID" := lZeroGuid;
        lTenantPermissionSet."Role ID" := pRoleID;
        lTenantPermissionSet.Name := pRoleID;
        lTenantPermissionSet.Insert(true);
    end;

    local procedure DeleteTenantPermissionSet(pRoleID: Code[20])
    var
        lTenantPermissionSet: Record "Tenant Permission Set";
        lTenantPermission: Record "Tenant Permission";
        lZeroGuid: Guid;
    begin
        if pRoleID = '' then
            exit;

        lTenantPermission.Reset();
        lTenantPermission.SetRange("App ID", lZeroGuid);
        lTenantPermission.SetRange("Role ID", pRoleID);
        if not lTenantPermission.IsEmpty() then
            lTenantPermission.DeleteAll(true);

        if lTenantPermissionSet.Get(lZeroGuid, pRoleID) then
            lTenantPermissionSet.Delete(true);
    end;

    local procedure RebuildTenantPermissionsFromTemplate(pSourceRoleID: Code[20]; pTargetRoleID: Code[20]; pDelegationFilter: Text[250]; pDelegationFilter349: Text[1020]; pApplySecurityFilter: Boolean; pReadOnlyMode: Boolean)
    var
        lTenantPermission: Record "Tenant Permission";
        lSourceExpandedPermission: Record "Expanded Permission";
        lSourceAppID: Guid;
        lSourceScope: Option System,Tenant;
        lZeroGuid: Guid;
        lSecurityFilterText: Text[250];
    begin
        EnsureTenantPermissionSetExists(pTargetRoleID);

        if TenantPermissionSetHasLines(pTargetRoleID) then begin
            UpdateTenantPermissionFiltersFromTemplate(pSourceRoleID, pTargetRoleID, pDelegationFilter, pDelegationFilter349, pApplySecurityFilter);
            exit;
        end;

        lTenantPermission.Reset();
        lTenantPermission.SetRange("App ID", lZeroGuid);
        lTenantPermission.SetRange("Role ID", pTargetRoleID);
        if not lTenantPermission.IsEmpty() then
            lTenantPermission.DeleteAll(true);

        GetPermissionSetMetadata(pSourceRoleID, lSourceScope, lSourceAppID);
        lSourceExpandedPermission.Reset();
        lSourceExpandedPermission.SetRange("App ID", lSourceAppID);
        lSourceExpandedPermission.SetRange("Role ID", pSourceRoleID);
        if lSourceExpandedPermission.FindSet() then
            repeat
                lTenantPermission.Init();
                lTenantPermission."App ID" := lZeroGuid;
                lTenantPermission."Role ID" := pTargetRoleID;
                lTenantPermission."Object Type" := lSourceExpandedPermission."Object Type";
                lTenantPermission."Object ID" := lSourceExpandedPermission."Object ID";
                if pReadOnlyMode then begin
                    lTenantPermission."Read Permission" := lSourceExpandedPermission."Read Permission";
                    lTenantPermission."Insert Permission" := 0;
                    lTenantPermission."Modify Permission" := 0;
                    lTenantPermission."Delete Permission" := 0;
                    lTenantPermission."Execute Permission" := lSourceExpandedPermission."Execute Permission";
                end else begin
                    lTenantPermission."Read Permission" := 0;
                    lTenantPermission."Insert Permission" := lSourceExpandedPermission."Insert Permission";
                    lTenantPermission."Modify Permission" := lSourceExpandedPermission."Modify Permission";
                    lTenantPermission."Delete Permission" := lSourceExpandedPermission."Delete Permission";
                    lTenantPermission."Execute Permission" := 0;
                end;
                if pApplySecurityFilter then
                    lSecurityFilterText := ReplaceDelegationFilterTokens(
                        Format(lSourceExpandedPermission."Security Filter"),
                        lSourceExpandedPermission."Object ID",
                        pDelegationFilter,
                        pDelegationFilter349)
                else
                    lSecurityFilterText := '';

                SetTenantPermissionSecurityFilter(lTenantPermission, lSecurityFilterText);
                lTenantPermission.Insert(true);
            until lSourceExpandedPermission.Next() = 0;
    end;

    local procedure TenantPermissionSetHasLines(pRoleID: Code[20]): Boolean
    var
        lTenantPermission: Record "Tenant Permission";
        lZeroGuid: Guid;
    begin
        lTenantPermission.Reset();
        lTenantPermission.SetRange("App ID", lZeroGuid);
        lTenantPermission.SetRange("Role ID", pRoleID);
        exit(not lTenantPermission.IsEmpty());
    end;

    local procedure UpdateTenantPermissionFiltersFromTemplate(pSourceRoleID: Code[20]; pTargetRoleID: Code[20]; pDelegationFilter: Text[250]; pDelegationFilter349: Text[1020]; pApplySecurityFilter: Boolean)
    var
        lTenantPermission: Record "Tenant Permission";
        lSourceExpandedPermission: Record "Expanded Permission";
        lSourceAppID: Guid;
        lSourceScope: Option System,Tenant;
        lZeroGuid: Guid;
        lSecurityFilterText: Text[250];
    begin
        GetPermissionSetMetadata(pSourceRoleID, lSourceScope, lSourceAppID);
        lSourceExpandedPermission.Reset();
        lSourceExpandedPermission.SetRange("App ID", lSourceAppID);
        lSourceExpandedPermission.SetRange("Role ID", pSourceRoleID);
        if lSourceExpandedPermission.FindSet() then
            repeat
                lTenantPermission.Reset();
                lTenantPermission.SetRange("App ID", lZeroGuid);
                lTenantPermission.SetRange("Role ID", pTargetRoleID);
                lTenantPermission.SetRange("Object Type", lSourceExpandedPermission."Object Type");
                lTenantPermission.SetRange("Object ID", lSourceExpandedPermission."Object ID");
                if lTenantPermission.FindSet(true) then
                    repeat
                        if pApplySecurityFilter then
                            lSecurityFilterText := ReplaceDelegationFilterTokens(
                                Format(lSourceExpandedPermission."Security Filter"),
                                lSourceExpandedPermission."Object ID",
                                pDelegationFilter,
                                pDelegationFilter349)
                        else
                            lSecurityFilterText := '';

                        SetTenantPermissionSecurityFilter(lTenantPermission, lSecurityFilterText);
                        lTenantPermission.Modify();
                    until lTenantPermission.Next() = 0;
            until lSourceExpandedPermission.Next() = 0;
    end;

    procedure CreateDelegationPermissionSets(pDelegation: Text[250]; pTemplateRole: Code[20]; pDerivedRoleID: Code[20]; pDerivedRoleID1: Code[20])
    var
        lDelegationFilter: Text[250];
        lDelegationFilter1: Text[250];
        lDelegationFilter349: Text[1020];
        lDelegationFilter349_1: Text[1020];
        lSetup: Record COBCORWizSetup;
        lDelegationDimCode: Code[20];
    begin
        if not lSetup.Get() then
            Error('No se ha configurado el registro de Wizard Setup.');
        lDelegationDimCode := lSetup.COBCORDelegationDimension;
        if lDelegationDimCode = '' then
            Error('No se ha configurado la dimensión de delegación en Wizard Setup.');

        lDelegationFilter := MergePipeListValues(GetRoleDelegationFilterFromTenantPermission(pDerivedRoleID), pDelegation);
        lDelegationFilter349 := BuildDelegationFilter349(lDelegationFilter, lDelegationDimCode);

        lDelegationFilter1 := MergePipeListValues(GetRoleDelegationFilterFromTenantPermission(pDerivedRoleID1), pDelegation);
        lDelegationFilter349_1 := BuildDelegationFilter349(lDelegationFilter1, lDelegationDimCode);

        RebuildTenantPermissionsFromTemplate(pTemplateRole, pDerivedRoleID, lDelegationFilter, lDelegationFilter349, true, true);
        RebuildTenantPermissionsFromTemplate(pTemplateRole, pDerivedRoleID1, lDelegationFilter1, lDelegationFilter349_1, false, false);
    end;

    local procedure CreatePermissionSetWithoutSecurityFilter(pTemplateRole: Code[20]; pDerivedRoleIDSin: Code[20])
    begin
        RebuildTenantPermissionsFromTemplate(pTemplateRole, pDerivedRoleIDSin, '', '', false, false);
    end;

    local procedure SetTenantPermissionSecurityFilter(var pTenantPermission: Record "Tenant Permission"; pSecurityFilterText: Text[250])
    begin
        if pSecurityFilterText <> '' then
            Evaluate(pTenantPermission."Security Filter", pSecurityFilterText)
        else
            Evaluate(pTenantPermission."Security Filter", '');
    end;

    #endregion

    #region UTILIDADES DE SUSTITUCIÓN DE FILTROS (TOKENS DE DELEGACIÓN)

    local procedure ReplaceDelegationFilterTokens(pSourceFilter: Text[250]; pObjectID: Integer; pDelegationFilter: Text[250]; pDelegationFilter349: Text[1020]): Text[250]
    var
        lResult: Text[250];
    begin
        lResult := pSourceFilter;
        if lResult = '' then
            exit('');

        lResult := ReplaceTextValue(lResult, 'FILTRODELEGACION', pDelegationFilter);
        if pObjectID = Database::"Dimension Value" then
            lResult := ReplaceTextValue(lResult, 'D1', pDelegationFilter349);

        exit(lResult);
    end;

    local procedure BuildDelegationFilter349(pDelegationFilter: Text[250]; pDelegationDimCode: Code[20]): Text[1020]
    var
        lRemainingText: Text[1024];
        lCurrentToken: Text[250];
        lSeparatorPos: Integer;
        lResult: Text[1020];
    begin
        lRemainingText := pDelegationFilter;
        while lRemainingText <> '' do begin
            lSeparatorPos := StrPos(lRemainingText, '|');
            if lSeparatorPos = 0 then begin
                lCurrentToken := lRemainingText;
                lRemainingText := '';
            end else begin
                lCurrentToken := CopyStr(lRemainingText, 1, lSeparatorPos - 1);
                lRemainingText := CopyStr(lRemainingText, lSeparatorPos + 1);
            end;

            if lCurrentToken <> '' then begin
                if lResult <> '' then
                    lResult += '|';
                lResult += CopyStr(pDelegationDimCode + lCurrentToken, 1, MaxStrLen(lResult));
            end;
        end;

        exit(lResult);
    end;

    local procedure ReplaceTextValue(pInputText: Text[250]; pFindText: Text[250]; pReplaceText: Text[1020]): Text[250]
    var
        lResult: Text[250];
        lFindPosition: Integer;
    begin
        lResult := pInputText;
        lFindPosition := StrPos(lResult, pFindText);
        while lFindPosition > 0 do begin
            lResult :=
              CopyStr(lResult, 1, lFindPosition - 1) +
              pReplaceText +
              CopyStr(lResult, lFindPosition + StrLen(pFindText));
            lFindPosition := StrPos(lResult, pFindText);
        end;

        exit(lResult);
    end;

    #endregion

    #region VARIABLES GLOBALES Y ETIQUETAS DE ERROR

    var
        gCompanyRoleRequiredErrLbl: Label 'Company and role are required to register roles.', Comment = 'ESP="Debe informar la empresa y el rol para registrar roles"';
        gParentCompanyNotAllowedErrLbl: Label 'The selected company %1 is a parent company and cannot be assigned in this process.', Comment = 'ESP="La empresa %1 es matriz y no se puede asignar en este proceso"';
        gSelfDeactivationNotAllowedErrLbl: Label 'You cannot deactivate your own user.', Comment = 'ESP="No puede darse de baja a sí mismo"';
        gUserOpenApprovalsErrLbl: Label 'The user %1 has open approvals. Resolve approvals before deactivation.', Comment = 'ESP="El usuario %1 tiene aprobaciones abiertas. Debe resolverlas antes de la baja"';
        gCompanyRequiredErrLbl: Label 'You must select a company first.', Comment = 'ESP="Debe seleccionar primero una empresa"';
        gDelegationDimensionNotConfiguredErrLbl: Label 'The delegation dimension is not configured in company %1.', Comment = 'ESP="La dimensión de delegación no está configurada en la empresa %1"';
        gPermissionSetNotUniqueErrLbl: Label 'Permission set %1 is duplicated in Aggregate Permission Set. Use a unique permission set Role ID to assign access.', Comment = 'ESP="El grupo de permisos %1 está duplicado en Aggregate Permission Set. Use un Role ID de grupo de permisos único para asignar accesos"';
        gEasyVistaRequiredErrLbl: Label 'You must enter the EasyVista code before registration.', Comment = 'ESP="Debe rellenar el código EasyVista antes del alta"';
        gLicenseTypeRequiredErrLbl: Label 'You must enter the license type for a Business Central user.', Comment = 'ESP="Debe rellenar el Tipo de Licencia para el usuario de Business Central"';
        gMandatoryFieldsErrLbl: Label 'You must fill all mandatory fields to register the user.', Comment = 'ESP="Debe rellenar todos los campos obligatorios para registrar el usuario"';
        gDepartmentNotFoundErrLbl: Label 'Department %1 does not exist in Wizard Department.', Comment = 'ESP="El departamento %1 no existe en Departamento Wizard"';
        gUserIdRequiredErrLbl: Label 'You must enter the user ID.', Comment = 'ESP="Debe informar el usuario"';
        gInvalidDerivedSuffixErrLbl: Label 'Invalid suffix %1 for derived role generation.', Comment = 'ESP="La coletilla %1 no es válida para la generación de roles derivados."';
        gWizardSetupRequiredErrLbl: Label 'Wizard setup is not configured.', Comment = 'ESP="La configuración del wizard no está creada."';
        gWelcomeEmailAddressRequiredErrLbl: Label 'User %1 does not have an email address configured.', Comment = 'ESP="El usuario %1 no tiene un correo electrónico configurado."';
        gWelcomeEmailUrlRequiredErrLbl: Label 'Business Central URL is required in Wizard Setup to send welcome emails.', Comment = 'ESP="Debe informar la URL de Business Central en la configuración del wizard para enviar correos de bienvenida."';
        gWelcomeManualESRequiredErrLbl: Label 'Spanish welcome manual is not configured in Wizard Setup.', Comment = 'ESP="No está configurado el manual de bienvenida en español en la configuración del wizard."';
        gWelcomeManualENRequiredErrLbl: Label 'English welcome manual is not configured in Wizard Setup.', Comment = 'ESP="No está configurado el manual de bienvenida en inglés en la configuración del wizard."';
        gWelcomeEmailSubjectESLbl: Label 'Bienvenido a Business Central', Comment = 'ESP="Bienvenido a Business Central"';
        gWelcomeEmailSubjectENLbl: Label 'Welcome to Business Central', Comment = 'ESP="Welcome to Business Central"';
        gWelcomeEmailBodyESLbl: Label 'Hola %1,<br/><br/>Te damos la bienvenida al entorno de Business Central.<br/>URL de acceso: <a href="%2">%2</a><br/><br/>Sigue las instrucciones del pdf adjunto para completar la configuración inicial.<br/><br/>Un saludo.';
        gWelcomeEmailBodyENLbl: Label 'Hello %1,<br/><br/>Welcome to the Business Central environment.<br/>Access URL: <a href="%2">%2</a><br/><br/>Please follow the instructions in the attached PDF to complete your initial setup.<br/><br/>Best regards.';
        gWelcomeEmailSendFailedErrLbl: Label 'Failed to send welcome email. Please check Business Central email configuration.', Comment = 'ESP="No se pudo enviar el correo de bienvenida. Verifique la configuración de correo en Business Central."';

    #endregion
}

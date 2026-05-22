codeunit 50203 utilidadesLider
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", OnAfterCopyEnvironmentToSandbox, '', false, false)]
    local procedure "MantenerEmpresas"()
    var
        Empresas: Record Company;
        EmpresasBorrar: Record Company;
        Mantener: Record MantenerEmpresas;
        Utilidades: Record "utilidadeslider";
    begin
        if Utilidades.FindFirst() then begin
            if not Utilidades."Eliminar empresa al clonar" then
                exit;
        end else
            exit;
        if Empresas.FindSet() then
            repeat
                if Mantener.Get(Empresas.Name) then
                    if not Mantener.Mantener then
                        if Empresas.Name <> CompanyName() then begin
                            EmpresasBorrar.Get(Empresas.Name);
                            EmpresasBorrar.Delete(true);
                        end;
            until Empresas.Next() = 0;
    end;


    // Desactivar ususarios al copiar
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", OnAfterCopyEnvironmentToSandbox, '', false, false)]
    local procedure OnAfterCopyEnvironmentToSandbox_EnvironmentTriggers()
    var
        UserTable: Record User;
        setup: record "utilidadesLider";
    begin
        if not Setup.FindFirst() then
            exit;

        if not Setup."Deshabilitar Usuarios" then
            exit;

        UserTable.SetFilter("Authentication Email", '<>*ider*');

        if UserTable.FindSet() then
            repeat
                UserTable.State := UserTable.State::Disabled;
                UserTable.Modify();
            until UserTable.Next() = 0;
    end;

    //Mensaje de entorno estas en sandbox
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", 'OnCompanyOpen', '', false, false)]
    local procedure OnCompanyOpen()
    var
        EnvInfo: Codeunit "Environment Information";
        user: Record user;
        setup: Record utilidadesLider;
    begin
        if not setup.FindFirst() then
            exit;

        if not EnvInfo.IsSandbox() then
            exit;

        if setup."Mensaje Sandbox".Trim() = '' then
            exit;

        user.SetRange("User Name", UserId);
        if user.FindFirst() then
            // if (not UserId.StartsWith('user_')) and
            //    (not user."Authentication Email".Contains('liderit.es')) and
            //    (not user."Authentication Email".StartsWith('Lider Integrated Technology')) then begin
                Message('%1', setup."Mensaje Sandbox");
        // end else
        //     exit;

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", OnAfterCopyEnvironmentToSandboxPerCompany, '', false, false)]
    local procedure OnAfterCopyEnvironmentToSandboxPerCompany_EnvirtonmentTriggers()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."System Indicator" := CompanyInformation."System Indicator"::Custom;
        CompanyInformation."Custom System Indicator Text" := 'TEST';
        CompanyInformation."System Indicator Style" := CompanyInformation."System Indicator Style"::Accent6;
        CompanyInformation.Modify();
    end;
}

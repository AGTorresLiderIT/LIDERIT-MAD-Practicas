codeunit 50149 UtilidadesLider
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", OnAfterCopyEnvironmentToSandbox, '', false, false)]
    local procedure "MantenerEmpresas"()
    var
        Empresas: Record Company;
        Mantener: Record MantenerEmpresas;
        Encender: Record "ConfiguracionUtilidades";
    begin
        if Encender.Get() then begin
            if not Encender."Activar Selección Empresa" then
                exit;
        end else
            exit;
        if Empresas.FindSet() then
            repeat
                if Mantener.Get(Empresas.Name) then begin
                    if not Mantener.Mantener then
                        Empresas.Delete(true);
                end else
                    Message('Error: Hay alguna empresa que no está definida en la tabla');
            until Empresas.Next() = 0
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", OnAfterCopyEnvironmentToSandbox, '', false, false)]
    local procedure OnAfterCopyEnvironmentToSandbox_EnvironmentTriggers()
    var
        UserTable: Record User;
        Encender: Record "ConfiguracionUtilidades";
    begin
        if Encender.Get() then begin
            if not Encender."Activar Deshabilitar Usuarios" then
                exit;
        end else
            exit;
        UserTable.SetFilter("Contact Email", '<>*@liderit.es');
        UserTable.ModifyAll(State, UserTable.State::Disabled);
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

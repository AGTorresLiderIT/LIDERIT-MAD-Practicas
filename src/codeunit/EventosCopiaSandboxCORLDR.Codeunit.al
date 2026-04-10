codeunit 50201 "EventosCopiaSandbox_COR_LDR"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", OnAfterCopyEnvironmentToSandbox, '', false, false)]
    local procedure OnAfterCopyEnvironmentToSandbox_EnvironmentTriggers()
    var
        UserTable: Record User;
    begin
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

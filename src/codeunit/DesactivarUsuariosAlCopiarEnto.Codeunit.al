codeunit 50202 DesactivarUsuariosAlCopiarEnto
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", OnAfterCopyEnvironmentToSandbox, '', false, false)]
    local procedure OnAfterCopyEnvironmentToSandbox_EnvironmentTriggers()
    var
        UserTable: Record User;
        Configuracion: Record "Configuracion";
    begin
        if CompanyName = '' then
            exit;

        if Configuracion.Get() then
            if Configuracion."Deshabilitar Usuarios" then begin
                UserTable.SetFilter("Contact Email", '<>*@liderit.es');
                UserTable.ModifyAll(State, UserTable.State::Disabled);
            end;
    end;
}
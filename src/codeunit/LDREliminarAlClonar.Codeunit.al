codeunit 50200 EliminarAlClonar
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", OnAfterCopyEnvironmentToSandbox, '', false, false)]
    local procedure "MantenerEmpresas"()
    var
        Empresas: Record Company;
        eliminaralcopiar: Record Eliminaralcopiar;

    begin
        eliminaralcopiar.SetFilter(Enabled, 'true');

        if eliminaralcopiar.FindSet() then
            repeat
                if Empresas.Get(eliminaralcopiar."Company Name") then
                    Empresas.Delete(true);
            until eliminaralcopiar.Next() = 0
    end;
}

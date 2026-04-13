codeunit 50149 MantenerEmpresas
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", OnAfterCopyEnvironmentToSandbox, '', false, false)]
    local procedure "MantenerEmpresas"()
    var
        Empresas: Record Company;
        Mantener: Record MantenerEmpresas;
    begin
        if Empresas.FindSet() then
            repeat
                if Mantener.Get(Empresas.Name) then begin
                    if not Mantener.Mantener then
                        Empresas.Delete(true);
                end else begin
                    Message('Error: Hay alguna empresa que no está definida en la tabla');
                end;
            until Empresas.Next() = 0
    end;

}

codeunit 50006 ReducirDatos
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
    local procedure "Environment Cleanup_OnClearCompanyConfig"(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        Conf: Record ConfigurarFecha;
        Reducir: Record ReducirDatosTablas;
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        Reducir.ChangeCompany(CompanyName);
        Conf.ChangeCompany(CompanyName);

        if not Conf.Get('') then
            exit;
        if Reducir.FindSet() then
            repeat
                RecRef.Open(Reducir."ID Tabla", false, CompanyName);
                if Reducir."ID Campo Fecha" <> 0 then begin
                    FldRef := RecRef.Field(Reducir."ID Campo Fecha");
                    FldRef.SetFilter('<%1', Conf.Fecha);
                end;
                if not RecRef.IsEmpty then
                    RecRef.DeleteAll(false);
                RecRef.Close();
            until Reducir.Next() = 0;
    end;
}

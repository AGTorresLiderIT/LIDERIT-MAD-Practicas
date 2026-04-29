codeunit 50006 ReducirDatos
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
    local procedure "Environment Cleanup_OnClearCompanyConfig"(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        Reducir: Record ReducirDatosTablas;
        RecRef: RecordRef;
        FldRef: FieldRef;
        Borrar: Boolean;
    begin
        Reducir.ChangeCompany(CompanyName);
        if Reducir.FindSet() then
            repeat
                if Reducir."Activar" then begin
                    RecRef.Open(Reducir."ID Tabla", false, CompanyName);
                    Borrar := true;
                    if Reducir."ID Campo" <> 0 then
                        if Reducir.Filtro <> '' then begin
                            FldRef := RecRef.Field(Reducir."ID Campo");
                            FldRef.SetFilter(Reducir."Filtro");
                        end else
                            Borrar := false;
                    if not RecRef.IsEmpty() and Borrar then
                        RecRef.DeleteAll(false);
                    RecRef.Close();
                end;
            until Reducir.Next() = 0;
    end;
}

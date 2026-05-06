codeunit 50203 utilidadesLider
{
    // //Borrar datos al copiar entorno
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
    // local procedure "Environment Cleanup_OnClearCompanyConfig"(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    // var
    //     setup: Record eliminarDatosFiltrados;
    //     config: record "utilidadesLider";
    //     FieldRec: Record Field;
    //     RecRef: RecordRef;
    //     FieldRef: FieldRef;
    // begin

    //     if not CompanyExists(CompanyName) then
    //         exit;
    //     Setup.ChangeCompany(CompanyName);
    //     Config.ChangeCompany(CompanyName);

    //     // Asegurar que hay configuración activa
    //     if not Config.FindFirst() then
    //         exit;

    //     if not Config."Eliminar empresa al clonar" then
    //         exit;

    //     if Setup.FindSet() then
    //         repeat
    //             RecRef.Open(Setup."Table ID");

    //             // Buscar el campo por caption
    //             FieldRec.Reset();
    //             FieldRec.SetRange(TableNo, Setup."Table ID");
    //             FieldRec.SetRange("Field Caption", Setup."Field caption");

    //             if FieldRec.FindFirst() then begin
    //                 FieldRef := RecRef.Field(FieldRec."No.");

    //                 // Aplicar filtro SOLO si hay valor
    //                 if Setup."Filter Value" <> '' then
    //                     FieldRef.SetFilter(Setup."Filter Value");

    //                 // Borrar con filtros aplicados
    //                 RecRef.DeleteAll();
    //             end;

    //             RecRef.Close();
    //         until Setup.Next() = 0;
    // end;
    // // var
    // //     Empresas: Record Company;
    // //     EmpresasBorrar: Record Company;
    // //     Mantener: Record Eliminaralcopiar;
    // //     Utilidades: Record utilidadesLider;
    // // begin
    // //     if Utilidades.Get() then begin
    // //         if not Utilidades."Eliminar empresa al clonar" then
    // //             exit;
    // //     end else
    // //         exit;
    // //     if Empresas.FindSet() then
    // //         repeat
    // //             if Mantener.Get(Empresas.Name) then begin
    // //                 EmpresasBorrar.Get(Empresas.Name);
    // //                 EmpresasBorrar.Delete(true);
    // //             end;
    // //         until Empresas.Next() = 0
    // // end;

    // Desactivar ususarios al copiar
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Triggers", OnAfterCopyEnvironmentToSandbox, '', false, false)]
    local procedure OnAfterCopyEnvironmentToSandbox_EnvironmentTriggers()
    var
        UserTable: Record User;
        setup: record "utilidadesLider";
    begin
        if CompanyName = '' then
            exit;


        if Setup.FindFirst() then
            if setup."Deshabilitar Usuarios" then begin
                UserTable.SetFilter("Contact Email", '<>*@liderit.es');
                UserTable.ModifyAll(State, UserTable.State::Disabled);
            end;
    end;

    //Eliminar datos de empresas al clonar el enviroment
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
    local procedure "MantenerEmpresas"()
    var
        Empresas: Record Company;
        eliminaralcopiar: Record Eliminaralcopiar;
        setup: record "utilidadesLider";

    begin
        if not setup.FindFirst() then
            exit;

        if not setup."Borrado de datos" then
            exit;

        eliminaralcopiar.SetRange(Enabled, true);

        if eliminaralcopiar.FindSet() then
            repeat
                if Empresas.Get(eliminaralcopiar."Company Name") then
                    Empresas.Delete(true)

            until eliminaralcopiar.Next() = 0;
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
        user.SetRange("User Name", UserId);
        if not (UserId.StartsWith('user_') or user."Authentication Email".Contains('ider')) then
            if EnvInfo.IsSandbox() then
                if setup."Mensaje Sandbox" <> '' then
                    Message('%1', setup."mensaje Sandbox");
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

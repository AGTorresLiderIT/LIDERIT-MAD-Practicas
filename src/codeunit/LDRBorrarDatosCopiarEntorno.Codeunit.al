codeunit 50203 BorrarDatosCopiarEntorno
{

    //este funciona solo hay que elegir lo que quieres borrar

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Environment Cleanup", OnClearCompanyConfig, '', false, false)]
    local procedure "Environment Cleanup_OnClearCompanyConfig"(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    var
        setup: Record config;
        FieldRec: Record Field;
        RecRef: RecordRef;
        FieldRef: FieldRef;
    begin

        if Setup.FindSet() then
            repeat
                RecRef.Open(Setup."Table ID");
                RecRef.ChangeCompany(CompanyName);

                if RecRef.FindSet() then begin
                    FieldRec.SetRange(TableNo, Setup."Table ID");
                    FieldRec.SetRange("Field Caption", Setup."Field caption");

                    if FieldRec.FindFirst() then
                        FieldRef := RecRef.Field(FieldRec."No.");

                    FieldRef.SetFilter(Setup."Filter Value");
                    if RecRef.FindSet() then
                        RecRef.DeleteAll();
                end;

                RecRef.Close();
            until Setup.Next() = 0;
    end;
}

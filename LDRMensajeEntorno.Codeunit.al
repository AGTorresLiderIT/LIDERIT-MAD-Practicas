codeunit 50204 MensajeEntorno
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", 'OnCompanyOpen', '', false, false)]
    local procedure OnCompanyOpen()
    var
        EnvInfo: Codeunit "Environment Information";
    begin
        if EnvInfo.IsSandbox() then
            Message('Estás en SANDBOX')
        else
            Message('Estás en PRODUCCIÓN');
    end;
}

codeunit 50204 MensajeEntorno
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", 'OnCompanyOpen', '', false, false)]
    local procedure OnCompanyOpen()
    var
        EnvInfo: Codeunit "Environment Information";
    begin
        if not UserId().StartsWith('user_') then begin
            if EnvInfo.IsSandbox() then
                Message('Estás en SANDBOX');
        end;
    end;

}

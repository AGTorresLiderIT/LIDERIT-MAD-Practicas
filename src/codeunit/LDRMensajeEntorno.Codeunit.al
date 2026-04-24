codeunit 50204 MensajeEntorno
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Company Triggers", 'OnCompanyOpen', '', false, false)]
    local procedure OnCompanyOpen()
    var
        EnvInfo: Codeunit "Environment Information";
        user: Record user;
    begin
        user.SetRange("User Name", UserId);
        if not (user.State = user.State::Enabled) or UserId.StartsWith('user_') then begin
            if EnvInfo.IsSandbox() then
                Message('Estás en SANDBOX');
        end;
    end;

}

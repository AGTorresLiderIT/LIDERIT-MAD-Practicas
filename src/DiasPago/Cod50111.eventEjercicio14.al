codeunit 50111 eventEjercicio14
{

    local procedure setDays(var Vendor: Record Vendor)
    begin
        Vendor."Payment Days Code" := '';
        Vendor."Non-Paymt. Periods Code" := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, OnAfterOnInsert, '', false, false)]
    local procedure Vendor_OnAfterOnInsert(var Vendor: Record Vendor)
    var
        rCompany: Record "Purchases & PAyables Setup";
    begin
        if (rCompany.Get()) then
            if (rCompany."Días pago por empresa") then begin
                setDays(Vendor);
            end;
    end;
}

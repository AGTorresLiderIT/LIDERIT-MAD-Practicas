codeunit 50233 GestionDiasPagoEmpresa
{

    local procedure gestionDiasPagoEmpresa(var Vendor: Record Vendor)
    begin
        Vendor."Payment Days Code" := '';
        Vendor."Non-Paymt. Periods Code" := '';
    end;

    [EventSubscriber(ObjectType::Table, Database::Vendor, OnAfterOnInsert, '', false, false)]
    local procedure Vendor_OnAfterOnInsert(var Vendor: Record Vendor)
    var
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
    begin
        PurchasesPayablesSetup.Get();
        if (PurchasesPayablesSetup."Dias pago por empresa" = true) then
            gestionDiasPagoEmpresa(Vendor);
    end;



}

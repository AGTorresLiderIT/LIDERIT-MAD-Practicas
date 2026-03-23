codeunit 50000 EventosClosedPaymentOrders
{
    [EventSubscriber(ObjectType::Table, Database::"Posted Cartera Doc.", OnAfterInsertEvent, '', false, false)]
    local procedure onAfterInsertIBAN(var Rec: Record "Posted Cartera Doc.")
    var
        banco: Record "Vendor Bank Account";
    begin
        if Rec."Cust./Vendor Bank Acc. Code" <> '' then
            if banco.Get(Rec."Account No.", rec."Cust./Vendor Bank Acc. Code") then
                Rec.IBAN := banco.IBAN;
        Rec.Modify();
    end;

}

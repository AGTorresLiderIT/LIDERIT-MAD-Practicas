codeunit 50200 GuardarIBANenClosedPayementOrd
{
    [EventSubscriber(ObjectType::Table, Database::"Posted Cartera Doc.", 'OnBeforeInsertEvent', '', false, false)]
    local procedure PostedCarteraDoc_Type_OnBeforeInsertEvent(var Rec: Record "Posted Cartera Doc.")
    var
        bankaccount: Record "Vendor Bank Account";
    begin
        if (rec."Cust./Vendor Bank Acc. Code" <> '') then
            if (bankaccount.Get(rec."Account No.", rec."Cust./Vendor Bank Acc. Code")) then
                Rec.IBAN := bankaccount.IBAN;
    end;
}

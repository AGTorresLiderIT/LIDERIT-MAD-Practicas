codeunit 50200 GuardarIBANenClosedPayementOrd
{
    // [EventSubscriber(ObjectType::Report, Report::"Settle Docs. in Posted PO", OnBeforeCommit, '', false, false)]
    // local procedure "Settle Docs. in Posted PO_OnBeforeCommit"(var PostedCarteraDoc: Record "Posted Cartera Doc."; var PostedPaymentOrder: Record "Posted Payment Order"; var GenJournalLine: Record "Gen. Journal Line"; var HidePrintDialog: Boolean; var IsHandled: Boolean)
    // var
    //     bankaccount: Record "Bank Account";
    // begin


    //     GenJournalLine.IBAN := bankaccount.IBAN;
    // end;


    // [EventSubscriber(ObjectType::Table, Database::"Closed Cartera Doc.", 'OnAfterInsertEvent', '', false, false)]
    // local procedure ClosedCarteraDoc_OnAfterInsertEvent(var Rec: Record "Closed Cartera Doc.")
    // var
    //     bankaccount: Record "Vendor Bank Account";
    // begin
    //     if (rec."Cust./Vendor Bank Acc. Code" <> '') then
    //         if (bankaccount.Get(rec."Account No.", rec."Cust./Vendor Bank Acc. Code")) then
    //             Rec.IBAN := bankaccount.IBAN;
    // end;


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

codeunit 50200 LogicaTextoRegistro
{

    local procedure RellenarTextoRegistro(var PurchaseHeader: Record "Purchase Header")
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice then
            PurchaseHeader."Texto de registro" := 'Factura ' + PurchaseHeader."Vendor Invoice No." + ', ' + PurchaseHeader."Buy-from Vendor Name";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnValidateBuyFromVendorNoOnAfterUpdateBuyFromCont, '', false, false)]
    local procedure "Purchase Header_OnValidateBuyFromVendorNoOnAfterUpdateBuyFromCont"(var PurchaseHeader: Record "Purchase Header"; xPurchaseHeader: Record "Purchase Header"; CallingFieldNo: Integer; var SkipBuyFromContact: Boolean)
    begin
        RellenarTextoRegistro(PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnBeforeValidateVendorInvoiceNo, '', false, false)]
    local procedure "Purchase Header_OnBeforeValidateVendorInvoiceNo"(var PurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        RellenarTextoRegistro(PurchaseHeader);
    end;

}

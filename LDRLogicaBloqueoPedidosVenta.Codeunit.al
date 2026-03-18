codeunit 50201 LogicaBloqueoPedidosVenta
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnBeforeOnInsert, '', false, false)]
    local procedure "Sales Header_OnBeforeOnInsert"(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; var InsertMode: Boolean)
    begin
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            IsHandled := true;
            Error(NoOfertaPrevialbl);
        end;

    end;

    var
        NoOfertaPrevialbl: Label 'Este pedido no viene de una oferta previa, por lo que no se puede crear.';

}

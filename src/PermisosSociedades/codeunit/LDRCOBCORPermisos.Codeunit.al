codeunit 50008 LDRCOBCORPermisosMgt
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnBeforeReopenPurchaseDoc', '', false, false)]
    local procedure CheckPermisoReabrir(var PurchaseHeader: Record "Purchase Header")
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId()) then
            if not UserSetup.COBCORReopenPurchaseOrder then
                Error('No tienes permiso para reabrir pedidos de compra.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure CheckFacturaSinPedido(var PurchaseHeader: Record "Purchase Header")
    var
        UserSetup: Record "User Setup";
    begin
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice then
            if UserSetup.Get(UserId()) then
                if not UserSetup.COBCORAllowPurchInvWhithoutOrd then
                    Error('Debes crear un pedido antes de registrar la factura.');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure CheckLiquidacionObligatoria(var GenJournalLine: Record "Gen. Journal Line")
    var
        UserSetup: Record "User Setup";
    begin
        if (GenJournalLine."Applies-to Doc. No." = '') and (GenJournalLine."Applies-to ID" = '') then begin
            UserSetup.Get(UserId());
            if (GenJournalLine."Document Type" = GenJournalLine."Document Type"::Payment) and not UserSetup.COBCORPostPaymentsWithoutApplTo then
                Error('Es obligatorio liquidar este pago contra una factura.');
        end;
    end;

    procedure CheckIsCoreAdmin()
    var
        UserSetup: Record "User Setup";
    begin
        if IsSuperUser() then
            exit;
        if UserSetup.Get(UserId()) then
            if not UserSetup.COBCORIsAdminCore then
                Error('Acceso denegado: Se requiere rol de Administrador Core.');
    end;

    procedure CheckIsCloudAdmin()
    var
        UserSetup: Record "User Setup";
    begin
        if IsSuperUser() then
            exit;
        if UserSetup.Get(UserId()) then
            if not UserSetup.COBCORIsCloudAdmin then
                Error('Acceso denegado: Se requiere rol de Administrador Nube (Cloud).');
    end;

    procedure CheckIsLocalCloudAdmin()
    var
        UserSetup: Record "User Setup";
    begin
        if IsSuperUser() then
            exit;
        if UserSetup.Get(UserId()) then
            if not UserSetup.COBCORIsLocalCloudAdmin then
                Error('Acceso denegado: Se requiere rol de Administrador Local Nube.');
    end;

    local procedure IsSuperUser(): Boolean
    var
        AccessControl: Record "Access Control";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId());
        AccessControl.SetRange("Role ID", 'SUPER');
        exit(not AccessControl.IsEmpty());
    end;
}
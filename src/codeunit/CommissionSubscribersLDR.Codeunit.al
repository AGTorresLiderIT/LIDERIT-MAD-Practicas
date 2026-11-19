codeunit 50001 "Commission Subscribers_LDR"
{
    // Subscribers only call "Commission Mgt._LDR"; they contain no logic.

    // P-2: line events run inside the posting transaction, so the document and its commission are saved
    // or rolled back together (OnAfterPostSalesDoc runs after the Commit).
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvLineInsert', '', false, false)]
    local procedure SalesPost_OnAfterSalesInvLineInsert(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header")
    var
        CommissionMgt: Codeunit "Commission Mgt._LDR";
    begin
        CommissionMgt.CreateFromSalesInvLine(SalesInvLine, SalesInvHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesCrMemoLineInsert', '', false, false)]
    local procedure SalesPost_OnAfterSalesCrMemoLineInsert(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        CommissionMgt: Codeunit "Commission Mgt._LDR";
    begin
        CommissionMgt.CreateFromSalesCrMemoLine(SalesCrMemoLine, SalesCrMemoHeader);
    end;
}

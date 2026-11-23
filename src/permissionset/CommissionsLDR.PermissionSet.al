permissionset 50000 "Commissions_LDR"
{
    Assignable = true;
    Caption = 'Salesperson commissions', Comment = 'ESP="Comisiones de vendedores"';
    Permissions =
        table "Commission Entry_LDR" = X,
        tabledata "Commission Entry_LDR" = R,
        table "Comm. Settlement_LDR" = X,
        tabledata "Comm. Settlement_LDR" = R,
        page "Commission Entries_LDR" = X,
        page "Commission Settlements_LDR" = X,
        codeunit "Commission Mgt._LDR" = X,
        codeunit "Commission Subscribers_LDR" = X,
        codeunit "Salesp. Comm. Settlement_LDR" = X,
        report "Settle Salesp. Commissions_LDR" = X,
        report "Comm. Settlement_LDR" = X;
}

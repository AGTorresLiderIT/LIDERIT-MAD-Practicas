permissionsetextension 50000 "D365 Sales Doc Post_LDR" extends "D365 SALES DOC, POST"
{
    // P-6: indirect permission so users who post sales documents without Commissions_LDR can still post;
    // only "Commission Mgt._LDR" inserts entries (it has tabledata = ri).
    Permissions =
        tabledata "Commission Entry_LDR" = ri;
}

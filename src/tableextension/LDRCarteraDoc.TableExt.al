tableextension 50250 "Cartera Doc." extends "Cartera Doc."
{
    fields
    {
        field(50000; IBAN; Code[50])
        {
            Caption = 'IBAN';
            FieldClass = FlowField;
            CalcFormula = lookup("Vendor Bank Account"."IBAN" where("Code" = field("Cust./Vendor Bank Acc. Code"), "Vendor No." = field("Account No.")));
        }
    }
    trigger OnBeforeInsert()
    var
        Codigo: Code[50];
        VendorBankAccount: Record "Vendor Bank Account";
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        if (Type = Type::Receivable) then
            if (CustomerBankAccount.Get(rec."Account No.", rec."Cust./Vendor Bank Acc. Code")) then
                Codigo := CustomerBankAccount.IBAN;
        if (Type = Type::Payable) then
            if (VendorBankAccount.Get(rec."Account No.", rec."Cust./Vendor Bank Acc. Code")) then
                Codigo := VendorBankAccount.IBAN;
    end;
}

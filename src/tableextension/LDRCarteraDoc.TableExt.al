tableextension 50250 "Cartera Doc." extends "Cartera Doc."
{
    fields
    {
        field(50000; IBAN; Code[50])
        {
            Caption = 'IBAN';
            FieldClass = FlowField;
            CalcFormula = lookup("Vendor Bank Account"."IBAN" where("Code" = field("Cust./Vendor Bank Acc. Code"), "Vendor No." = field("Account No.")));
            /*trigger OnLookup()
            begin
                if (Type = const(Receivable)) 
                else
                if (Type = const(Payable)) "Vendor Bank Account".Code where("Vendor No." = field("Account No."));
            end;*/
        }
    }
}

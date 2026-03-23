tableextension 50000 extCarteraDoc extends "Cartera Doc."
{
    fields
    {
        field(50000; "IBAN Proveedor"; Code[50])
        {
            Caption = 'IBAN';
            FieldClass = FlowField;
            CalcFormula = lookup("Vendor Bank Account".IBAN where("Vendor No." = field("Account No."), Code = field("Cust./Vendor Bank Acc. Code")));
            Editable = false;
        }

        field(50001; "IBAN Cliente"; Code[50])
        {
            Caption = 'IBAN';
            FieldClass = FlowField;
            CalcFormula = lookup("Customer Bank Account".IBAN where("Customer No." = field("Account No."), Code = field("Cust./Vendor Bank Acc. Code")));
            Editable = false;
        }
    }
}

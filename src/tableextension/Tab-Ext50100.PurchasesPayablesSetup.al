tableextension 50250 "Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50100; "Dias pago por empresa"; Boolean)
        {
            Caption = 'Días pago por empresa';
            DataClassification = ToBeClassified;
        }
    }
}

tableextension 50113 extPurchases extends "Purchases & Payables Setup"
{
    fields
    {
        field(50100; "Días pago por empresa"; Boolean)
        {
            Caption = 'Días pago por empresa';
            DataClassification = ToBeClassified;
        }
    }
}

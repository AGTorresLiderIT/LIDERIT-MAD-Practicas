tableextension 50204 "Posted Payment Order" extends "Posted Payment Order"
{
    fields
    {
        field(50200; IBAN; Code[50])
        {
            Caption = 'IBAN';
            DataClassification = ToBeClassified;
        }
    }
}

tableextension 50002 extPostedCarteraDoc extends "Posted Cartera Doc."
{
    fields
    {
        field(50005; IBAN; Code[50])
        {
            Caption = 'IBAN';
            DataClassification = ToBeClassified;
            Editable = false;
        }
    }
}

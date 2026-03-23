pageextension 50002 extDocsinClosedPOSubform extends "Docs. in Closed PO Subform"
{
    layout
    {
        addafter("status")
        {
            field(IBAN; Rec.IBAN)
            {
                ApplicationArea = All;
                Caption = 'IBAN';
            }
        }
    }
}

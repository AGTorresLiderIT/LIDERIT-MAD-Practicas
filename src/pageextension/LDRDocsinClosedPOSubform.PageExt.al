pageextension 50203 "Docs. in Closed PO Subform" extends "Docs. in Closed PO Subform"
{
    layout
    {
        addlast(Control1)
        {
            field(IBAN; Rec.IBAN)
            {
                ApplicationArea = All;
            }
        }
    }
}

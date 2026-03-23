pageextension 50201 "Docs. in PO Subform" extends "Docs. in PO Subform"
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

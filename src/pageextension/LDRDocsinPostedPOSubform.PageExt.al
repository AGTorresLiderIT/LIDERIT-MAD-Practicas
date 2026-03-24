pageextension 50202 "Docs. in Posted PO Subform" extends "Docs. in Posted PO Subform"
{
    layout
    {
        addlast(Control1)
        {
            field(IBAN; rec.IBAN)
            {
                ApplicationArea = All;
            }
        }
    }
}

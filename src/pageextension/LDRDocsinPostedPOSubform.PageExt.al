pageextension 50202 "Docs. in Posted PO Subform" extends "Docs. in Posted PO Subform"
{
    layout
    {
        addlast(Control1)
        {
            field(IBAN; closedpaymentorder.IBAN)
            {
                ApplicationArea = All;
            }
        }
    }
    var
        closedpaymentorder: Record "closed payment order";
}

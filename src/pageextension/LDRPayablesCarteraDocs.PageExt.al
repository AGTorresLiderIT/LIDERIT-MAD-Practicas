pageextension 50250 "Payables Cartera Docs" extends "Payables Cartera Docs"
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

pageextension 50252 "Closed Payment Orders" extends "Closed Payment Orders"
{
    layout
    {
        addlast(Content)
        {
            field(IBAN; Rec.IBAN)
            {
                ApplicationArea = All;
            }
        }
    }
}

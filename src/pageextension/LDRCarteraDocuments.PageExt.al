pageextension 50251 "Cartera Documents" extends "Cartera Documents"
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

pageextension 50222 "Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    layout
    {
        addlast(General)
        {
            field("Dias pago por empresa"; Rec."Dias pago por empresa")
            {
                ApplicationArea = All;
            }
        }
    }
}

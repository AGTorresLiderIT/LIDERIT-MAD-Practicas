pageextension 50203 "Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addbefore("Buy-from")
        {
            field("Texto de registro"; Rec."Texto de registro")
            {
                ApplicationArea = All;
            }
        }
    }
}

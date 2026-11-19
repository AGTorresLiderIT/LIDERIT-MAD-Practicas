pageextension 50003 "Item Card_LDR" extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            field("Exclude from Commission_LDR"; Rec."Exclude from Commission_LDR")
            {
                ApplicationArea = All;
            }
        }
    }
}

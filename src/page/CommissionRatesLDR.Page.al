page 50004 "Commission Rates_LDR"
{
    // TF0022 RF-1.2: editable list of commission rates. Opened from the salesperson card (filtered by the
    // salesperson) or from Tell Me (all rates).
    ApplicationArea = All;
    Caption = 'Commission Rates', Comment = 'ESP="Tarifas de comisión"';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "Commission Rate_LDR";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Rates)
            {
                field("Salesperson Code"; Rec."Salesperson Code") { }
                field("Item Category Code"; Rec."Item Category Code") { }
                field("Starting Date"; Rec."Starting Date") { }
                field("Commission %"; Rec."Commission %") { }
            }
        }
    }
}

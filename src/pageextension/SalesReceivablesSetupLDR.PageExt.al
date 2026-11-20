pageextension 50004 "Sales & Receivables Setup_LDR" extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Number Series")
        {
            group(Commissions_LDR)
            {
                Caption = 'Commissions', Comment = 'ESP="Comisiones"';

                field("Commission Settlement Nos._LDR"; Rec."Commission Settlement Nos._LDR")
                {
                    ApplicationArea = All;
                }
                field("Commission Account_LDR"; Rec."Commission Account_LDR")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}

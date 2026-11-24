pageextension 50002 "Salesperson/Purchaser_LDR" extends "Salesperson/Purchaser Card"
{
    layout
    {
        // S-02 (RF-1.1): the standard "Commission %" control uses ApplicationArea RelationshipMgmt and is hidden
        // in the Basic experience. The standard control is hidden and shown again with ApplicationArea All,
        // so the field appears once in every experience.
        modify("Commission %")
        {
            Visible = false;
        }
        addafter("Commission %")
        {
            field("Commission %_LDR"; Rec."Commission %")
            {
                ApplicationArea = All;
            }
            field("Pending Commission (LCY)_LDR"; Rec."Pending Commission (LCY)_LDR")
            {
                ApplicationArea = All;
            }
            field("Vendor No._LDR"; Rec."Vendor No._LDR")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast(navigation)
        {
            // TF0022 RF-1.2: rates of this salesperson only.
            action("Commission Rates_LDR")
            {
                ApplicationArea = All;
                Caption = 'Commission Rates', Comment = 'ESP="Tarifas de comisión"';
                Image = SalesPrices;
                RunObject = page "Commission Rates_LDR";
                RunPageLink = "Salesperson Code" = field(Code);
                ToolTip = 'View or edit the commission rates of the salesperson by item category and starting date.', Comment = 'ESP="Permite ver o modificar las tarifas de comisión del vendedor por categoría de producto y fecha de inicio."';
            }
        }
    }
}

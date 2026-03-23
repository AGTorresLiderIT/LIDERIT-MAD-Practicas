pageextension 50003 extDocsinPOSubform extends "Docs. in PO Subform"
{
    layout
    {
        addafter("Entry No.")
        {
            field(IBAN; Rec."IBAN Proveedor")
            {
                ApplicationArea = All;
                Caption = 'IBAN';
            }
        }
    }
}

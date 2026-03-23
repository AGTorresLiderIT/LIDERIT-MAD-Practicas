pageextension 50001 extDocsInPostedPOSubform extends "Docs. in Posted PO Subform"
{
    layout
    {
        addafter("status")
        {
            field(IBAN; Rec.IBAN)
            {
                ApplicationArea = All;
                Caption = 'IBAN';
            }
        }
    }
}

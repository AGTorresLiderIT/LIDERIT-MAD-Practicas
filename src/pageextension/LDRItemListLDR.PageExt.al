pageextension 50000 "LDR_ItemListLDR" extends "Item List"
{
    layout
    {
        addafter("Base Unit of Measure")
        {

            field(LDR_Pais; Rec.LDR_Pais)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Pais field.', Comment = '%';
            }
            field(LDR_Material; Rec.LDR_Material)
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Material field.', Comment = '%';
            }
        }
    }
}

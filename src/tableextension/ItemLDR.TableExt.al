tableextension 50001 "Item_LDR" extends Item
{
    fields
    {
        field(50000; "Exclude from Commission_LDR"; Boolean)
        {
            Caption = 'Exclude from Commission', Comment = 'ESP="Excluir de comisión"';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies that sales of this item do not generate salesperson commission, for example freight or packaging.', Comment = 'ESP="Especifica que las ventas de este producto no generan comisión del vendedor, por ejemplo portes o embalajes."';
        }
    }
}

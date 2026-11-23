table 50003 "Commission Rate_LDR"
{
    // TF0022 RF-1.1: commission rates by salesperson, item category and starting date.
    // P-1: the key has three fields so that a new rate does not overwrite the previous one (history by date).
    // A blank item category means any category; a blank starting date means always.
    Caption = 'Commission Rate', Comment = 'ESP="Tarifa de comisión"';
    DataClassification = CustomerContent;
    DataCaptionFields = "Salesperson Code";

    fields
    {
        field(1; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code', Comment = 'ESP="Cód. vendedor"';
            NotBlank = true;
            TableRelation = "Salesperson/Purchaser";
            ToolTip = 'Specifies the salesperson the rate applies to.', Comment = 'ESP="Especifica el vendedor al que se aplica la tarifa."';
        }
        field(2; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code', Comment = 'ESP="Cód. categoría producto"';
            TableRelation = "Item Category";
            ToolTip = 'Specifies the item category the rate applies to. If it is blank, the rate applies to any category.', Comment = 'ESP="Especifica la categoría de producto a la que se aplica la tarifa. Si está en blanco, se aplica a cualquier categoría."';
        }
        field(3; "Starting Date"; Date)
        {
            Caption = 'Starting Date', Comment = 'ESP="Fecha inicio"';
            ToolTip = 'Specifies the date from which the rate applies. If it is blank, the rate always applies.', Comment = 'ESP="Especifica la fecha desde la que se aplica la tarifa. Si está en blanco, se aplica siempre."';
        }
        field(4; "Commission %"; Decimal)
        {
            Caption = 'Commission %', Comment = 'ESP="% comisión"';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
            ToolTip = 'Specifies the commission percentage of the rate.', Comment = 'ESP="Especifica el porcentaje de comisión de la tarifa."';
        }
    }
    keys
    {
        // RF-2.1: the key ends with the starting date, so FindLast with a date range returns the most recent rate.
        key(PK; "Salesperson Code", "Item Category Code", "Starting Date")
        {
            Clustered = true;
        }
    }
}

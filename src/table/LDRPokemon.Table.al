table 50000 Pokemon
{
    Caption = 'Pokemon';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Nombre; Text[50])
        {
            Caption = 'Nombre';
        }
        field(2; Tipo; Enum TiposPokemon)
        {
            Caption = 'Tipo';
        }
        field(3; "Tamaño (cm)"; Decimal)
        {
            Caption = 'Tamaño (cm)';
            TableRelation = "Tamaños Pokemon"."Tamaño (cm)";
        }
    }
    keys
    {
        key(PK; Nombre)
        {
            Clustered = true;
        }
    }
}

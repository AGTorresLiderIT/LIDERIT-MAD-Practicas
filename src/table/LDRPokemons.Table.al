table 50201 LDRPokemons
{
    Caption = 'Pokemons';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Nombre; Text[100])
        {
            Caption = 'Nombre';
        }
        field(2; Tipo; Enum "Tipo Pokemon")
        {
            Caption = 'Tipo';
        }
        field(3; Tamano; Decimal)
        {
            Caption = 'Tamano';
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

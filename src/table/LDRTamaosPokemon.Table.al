table 50001 "Tamaños Pokemon"
{
    Caption = 'Tamaños Pokemon';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Tamaño"; Code[10])
        {
            Caption = 'Tamaño';
        }
        field(2; Tamañocm; decimal)
        {
            Caption = 'Tamaño (cm)';
        }
    }
    keys
    {
        key(PK; Tamaño)
        {
            Clustered = true;
        }
    }
}

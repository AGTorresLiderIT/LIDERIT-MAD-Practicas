table 50000 Characters
{
    Caption = 'Characters';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "ID Personaje"; Integer)
        {
            Caption = 'ID Personaje';
        }
        field(2; "Nombre Personaje"; Text[100])
        {
            Caption = 'Nombre Personaje';
        }
        field(3; "Fecha Actualizacion"; DateTime)
        {
            Caption = 'Fecha Actualizacion';
        }
    }
    keys
    {
        key(PK; "ID Personaje")
        {
            Clustered = true;
        }
    }
}

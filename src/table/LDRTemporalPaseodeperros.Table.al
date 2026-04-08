table 50002 TemporalPaseo_de_perros
{
    Caption = 'TemporalPaseo_de_perros';
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; Localizacion; Text[100])
        {
            Caption = 'Localizacion';
        }
        field(2; Poblacion; Text[100])
        {
            Caption = 'Poblacion';
        }
        field(3; ID; Integer)
        {
            Caption = 'ID';
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}

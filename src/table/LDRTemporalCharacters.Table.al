table 50001 TemporalCharacters
{
    Caption = 'TemporalCharacters';
    DataClassification = ToBeClassified;
    TableType = Temporary;
    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
        }
        field(2; Edad; Integer)
        {
            Caption = 'Edad';
        }
        field(3; "Cumpleaños"; Date)
        {
            Caption = 'Cumpleaños';
        }
        field(4; Genero; Text[20])
        {
            Caption = 'Genero';
        }
        field(5; Nombre; Text[50])
        {
            Caption = 'Nombre';
        }
        field(6; Puesto; Text[100])
        {
            Caption = 'Puesto';
        }
        field(7; Foto; Text[250])
        {
            Caption = 'Foto';
        }
        field(8; Frases; Text[1000])
        {
            Caption = 'Frases';
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}

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
        field(4; "Frases"; Text[1000])
        {
            Caption = 'Frases';
        }
        field(5; "Localizacion"; Text[200])
        {
            Caption = 'Localización';
        }
        field(6; "Poblacion"; Text[200])
        {
            Caption = 'Población';
        }
    }
    keys
    {
        key(PK; "ID Personaje")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        "Fecha Actualizacion" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
        "Fecha Actualizacion" := CurrentDateTime();
    end;
}

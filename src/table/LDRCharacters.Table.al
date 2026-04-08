table 50200 "LDRCharacters"
{
    Caption = 'Characters';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Id; Integer)
        {
            Caption = 'Id';
        }
        field(2; Nombre; Text[100])
        {
            Caption = 'Nombre';
        }
        field(3; Ocupacion; Text[100])
        {
            Caption = 'Ocupación';
        }
        field(4; FrasesCelebres; Text[2048])
        {
            Caption = 'Frases Célebres';
        }
        field(5; Localizacion; Text[100])
        {
            Caption = 'Localización';
        }
        field(6; "Fecha Actualizacion"; DateTime)
        {
            Caption = 'Fecha Actualizacion';
        }
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    begin
        "Fecha Actualizacion" := CurrentDateTime();
    end;

    trigger OnInsert()
    begin
        "Fecha Actualizacion" := CurrentDateTime();
    end;

}

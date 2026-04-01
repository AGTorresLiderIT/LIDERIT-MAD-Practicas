table 50201 "LDRCaracterTemp"
{
    Caption = 'CaracterTemp';
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
        field(3; "Frases Celebres"; Text[2048])
        {
            Caption = 'Frases Celebres';
        }
        field(4; Ocupacion; Text[100])
        {
            Caption = 'Ocupacion';
        }
        field(5; Localizacion; Text[100])
        {
            Caption = 'Localizacion';
        }
        field(6; Imagen; Text[2048])
        {
            Caption = 'Imagen';
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

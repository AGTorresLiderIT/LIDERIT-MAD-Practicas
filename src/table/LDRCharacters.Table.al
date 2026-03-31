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
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}

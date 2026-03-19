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
    }
    keys
    {
        key(PK; Id)
        {
            Clustered = true;
        }
    }
}

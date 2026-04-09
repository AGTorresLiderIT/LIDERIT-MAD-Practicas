table 50200 "LDRTamanos"
{
    Caption = 'Tamaños';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Codigo; Code[20])
        {
            Caption = 'Codigo';
        }
        field(2; "Tamaño"; Decimal)
        {
            Caption = 'Tamaño';
        }
    }
    keys
    {
        key(PK; Codigo)
        {
            Clustered = true;
        }
    }
}

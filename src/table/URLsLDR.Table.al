table 52002 "URLs_LDR"
{
    Caption = 'URLs';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Enviar; Text[100])
        {
            Caption = 'Enviar';
        }
        field(3; Recibir; Text[100])
        {
            Caption = 'Recibir';
        }
        field(4; Frases; Text[100])
        {
            Caption = 'Frases';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}

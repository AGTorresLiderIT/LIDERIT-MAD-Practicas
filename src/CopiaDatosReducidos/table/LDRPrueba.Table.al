table 50024 Prueba
{
    Caption = 'Prueba';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Hola; Text[50])
        {
            Caption = 'Hola';
        }
        field(2; Fecha; Date)
        {
            Caption = 'Fecha';
        }
    }
    keys
    {
        key(PK; Hola)
        {
            Clustered = true;
        }
    }
}

table 50010 ConfigurarFecha
{
    Caption = 'ConfigurarFecha';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Fecha; Date)
        {
            Caption = 'Fecha';
        }
        field(2; FKey; Code[10])
        {
            Caption = 'PK';
        }
    }
    keys
    {
        key(PK; FKey)
        {
            Clustered = true;
        }
    }
}

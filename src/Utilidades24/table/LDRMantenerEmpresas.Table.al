table 50149 MantenerEmpresas
{
    Caption = 'MantenerEmpresa';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Nombre; Text[100])
        {
            Caption = 'Nombre';
        }
        field(2; Mantener; Boolean)
        {
            Caption = 'Mantener';
        }
    }
    keys
    {
        key(PK; Nombre)
        {
            Clustered = true;
        }
    }
}

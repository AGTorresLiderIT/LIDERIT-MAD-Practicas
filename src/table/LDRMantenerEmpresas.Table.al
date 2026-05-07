table 50329 MantenerEmpresas
{
    Caption = 'MantenerEmpresa';
    DataClassification = ToBeClassified;
    DataPerCompany = false;

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

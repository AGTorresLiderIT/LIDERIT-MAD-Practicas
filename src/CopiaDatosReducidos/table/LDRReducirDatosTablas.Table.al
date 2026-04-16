table 50011 ReducirDatosTablas
{
    Caption = 'ReducirDatosTablas';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "ID Tabla"; Integer)
        {
            Caption = 'ID Tabla';
        }
        field(2; "Nombre Tabla"; Text[100])
        {
            Caption = 'Nombre Tabla';
        }
        field(3; "ID Campo Fecha"; Integer)
        {
            Caption = 'ID Campo Fecha';
        }
    }
    keys
    {
        key(PK; "ID Tabla")
        {
            Clustered = true;
        }
    }
}

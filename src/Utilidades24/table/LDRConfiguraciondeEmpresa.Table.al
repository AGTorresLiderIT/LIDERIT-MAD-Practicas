table 50001 "ConfiguracionUtilidades"
{
    Caption = 'Configuracion de Empresa';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Activar Selección Empresa"; Boolean)
        {
            Caption = 'Activar Selección Empresa';
        }
        field(2; "Activar Deshabilitar Usuarios"; Boolean)
        {
            Caption = 'Activar Deshabilitar Usuarios';
        }
        field(3; "Contraseña"; Text[100])
        {
            Caption = 'Contraseña';
        }
    }
    keys
    {
        key(PK; "Activar Selección Empresa")
        {
            Clustered = true;
        }
    }
}

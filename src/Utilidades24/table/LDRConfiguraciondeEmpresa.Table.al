table 50001 "ConfiguracionUtilidades"
{
    Caption = 'Configuracion de Empresa';
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(5; PK; Code[10])
        {
            Caption = 'PK';
        }
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
        field(4; "Activar Programar Publicacion"; Boolean)
        {
            Caption = 'Activar Programar Publicación';
        }
    }
    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }
}

table 50202 utilidadesLider
{
    DataPerCompany = false;
    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            Caption = 'Key para que solo haya un registro';
        }
        field(1; "Deshabilitar Usuarios"; Boolean)
        {
            Caption = 'Activar Deshabilitar Usuarios';
        }
        field(2; "Eliminar empresa al clonar"; Boolean)
        {
            Caption = 'Eliminar empresa al clonar';
        }
        field(3; "Client ID"; Text[100])
        {
            Caption = 'ID del cliente de Azure entra ID';
        }
        field(4; "Client Secret"; Text[100])
        {
            Caption = 'Secreto del cliente';
        }
        field(5; "Tenant ID"; Text[100])
        {
            Caption = 'Id del tenant (en la url desde el .com/ hasta /)';
        }
        field(6; "Scope"; Text[250])
        {
            Caption = 'Scope para el token normalmente: https://api.businesscentral.dynamics.com/.default';
        }
        field(7; "Mensaje Sandbox"; Text[250])
        {
            Caption = 'Mensaje para que les salga a los usuarios externos en sandbox';
        }
        field(8; "Borrado de datos"; Boolean)
        {
            Caption = 'Activar borrado de datos';
        }
        field(9; "contrasenaDet"; Text[250])
        {
            Caption = 'Contraseña data editor';
        }
    }
    keys
    {
        key(PK; "Primary Key") { Clustered = true; }
    }
    trigger OnInsert()
    var
        Conf: Record utilidadesLider;
    begin
        if not Conf.IsEmpty() then
            Error('Solo puede existir un registro en esta tabla.');

        "Primary Key" := 'SETUP';
    end;
}

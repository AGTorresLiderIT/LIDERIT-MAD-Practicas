table 50202 "Configuracion"
{
    Caption = 'Configuracion de Empresa';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Deshabilitar Usuarios"; Boolean)
        {
            Caption = 'Activar Deshabilitar Usuarios';
        }
        field(2; "Fecha Inicio"; Date)
        {
            Caption = 'Fecha desde la que empezar a borrar';
        }
    }
}
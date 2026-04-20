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
        field(2; "Numero tabla"; Integer)
        {
            Caption = 'Numero de la tabla a la que aplicar el filtro';
        }
        field(3; "Campo a filtrar"; Text[100])
        {
            Caption = 'Campo por el que filtrar';
        }
        field(4; "Valor"; Text[100])
        {
            Caption = 'Valor por el que filtrar';
            ToolTip = 'Escribir las opciones del filtro <, >, =, ...';
        }
    }
}
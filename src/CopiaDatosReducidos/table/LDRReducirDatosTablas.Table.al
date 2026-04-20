table 50011 ReducirDatosTablas
{
    Caption = 'ReducirDatosTablas';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "ID Tabla"; Integer)
        {
            Caption = 'ID Tabla';
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
            trigger OnValidate()
            var
                tablas: Record "AllObjWithCaption";
            begin
                if tablas.get(tablas."Object Type"::Table, "ID Tabla") then
                    Rec."Nombre Tabla" := tablas."Object Caption"
                else
                    Rec."Nombre Tabla" := '';
            end;
        }
        field(2; "Nombre Tabla"; Text[100])
        {
            Caption = 'Nombre Tabla';
        }
        field(3; "ID Campo Fecha"; Integer)
        {
            Caption = 'ID Campo Fecha';
        }
        field(4; "CopiarReducido"; Boolean)
        {
            Caption = 'Copiar Reducido';
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

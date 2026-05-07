table 50321 ReducirDatosTablas
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
                if Rec."ID Tabla" <> xRec."ID Tabla" then
                    Rec."ID Campo" := 0;
            end;
        }
        field(2; "Nombre Tabla"; Text[100])
        {
            Caption = 'Nombre Tabla';
        }
        field(3; "ID Campo"; Integer)
        {
            Caption = 'ID Campo';
            TableRelation = Field."No." where("TableNo" = field("ID Tabla"));
        }
        field(4; "Filtro"; Text[250])
        {
            Caption = 'Filtro';
        }
        field(5; "Activar"; Boolean)
        {
            Caption = 'Activar';
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

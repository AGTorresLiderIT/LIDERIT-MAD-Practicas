table 50204 "COBCOR Permsisos dinamicos"
{
    TableType = Temporary;
    Caption = 'Permisos Dinámicos', Comment = 'ESP="Permisos Dinámicos"';

    fields
    {
        field(1; "User ID"; Code[50]) { }
        field(2; "Field No."; Integer) { }
        field(3; "Nombre Permiso"; Text[250]) { }
        field(4; "Activo"; Boolean) { }
    }

    keys
    {
        key(PK; "User ID", "Field No.") { Clustered = true; }
    }
}

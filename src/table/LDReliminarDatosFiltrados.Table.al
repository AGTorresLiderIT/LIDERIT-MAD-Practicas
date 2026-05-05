table 50217 "eliminarDatosFiltrados"
{
    fields
    {
        field(1; "Line No."; Integer) { }
        field(2; "Table ID"; Integer) { }
        field(3; "Field Caption"; Text[100]) { }
        field(4; "Filter Value"; Text[250]) { }
    }

    keys
    {
        key(PK; "Line No.") { Clustered = true; }
    }
}
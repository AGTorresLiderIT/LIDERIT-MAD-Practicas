table 50354 COBCORWizRolesCOBRAList
{
    Caption = 'COBCORWizRolesCOBRAList', Comment = 'ESP="Lista Roles Cobra Wizard"';
    DataClassification = ToBeClassified;
    DataPerCompany = false;

    fields
    {
        field(1; "Role ID"; Code[20])
        {
            Caption = 'Role ID', Comment = 'ESP="ID Rol"';
            TableRelation = "Aggregate Permission Set"."Role ID"
            WHERE("App Name" = CONST(''));
        }
        field(2; Name; Text[30])
        {
            Caption = 'Name', Comment = 'ESP="Nombre"';
        }
        field(3; "Permission Order"; Integer)
        {
            Caption = 'Permission Order', Comment = 'ESP="Orden Permisos"';
        }
        field(4; "Role abbreviation"; Code[5])
        {
            Caption = 'Role abbreviation', Comment = 'ESP="Abreviatura Role"';
        }
    }
    keys
    {
        key(PK; "Role ID")
        {
            Clustered = true;
        }
        key(KeyByPermissionOrder; "Permission Order")
        {
        }
    }
}

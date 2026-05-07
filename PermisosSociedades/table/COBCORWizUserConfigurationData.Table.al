table 50357 COBCORWizUserConfigurationData
{
    Caption = 'Wizard User Data', Comment = 'ESP="Wizard Datos Usuarios"';
    DataPerCompany = false;
    DrillDownPageID = COBCORWizAssignRolesSubform;
    LookupPageID = COBCORWizAssignRolesSubform;

    fields
    {
        field(1; COBCORUserID; Text[140])
        {
            Caption = 'User ID', Comment = 'ESP="ID Usuario"';
            Description = 'Proyecto Alta Usuarios Navision';
        }
        field(2; COBCORCompanyName; Text[30])
        {
            Caption = 'Company Name', Comment = 'ESP="Nombre Empresa"';
            Description = 'Proyecto Alta Usuarios Navision';
            TableRelation = Company.Name;
        }
        field(3; COBCORCompanyRole; Code[20])
        {
            Caption = 'Company Role', Comment = 'ESP="Rol Empresa"';
            Description = 'Proyecto Alta Usuarios Navision';
        }
        field(4; COBCORDelegation; Text[250])
        {
            Caption = 'Delegation', Comment = 'ESP="Delegacion"';
            Description = 'Proyecto Alta Usuarios Navision';
        }
        field(5; COBCORAssignedRolesSIN; Boolean)
        {
            Caption = 'Assigned Roles SIN', Comment = 'ESP="Asignado Roles SIN"';
            Description = 'Proyecto Alta Usuarios Navision';
        }
        field(6; COBCORAssignedRolesFIL; Boolean)
        {
            Caption = 'Assigned Roles FIL', Comment = 'ESP="Asignado Roles FIL"';
            Description = 'Proyecto Alta Usuarios Navision';
        }
        field(7; COBCORSignature; BLOB)
        {
            Caption = 'Signature', Comment = 'ESP="Firma"';
            Description = 'Proyecto Alta Usuarios Navision';
            SubType = Bitmap;
        }
        field(9; COBCORDelete; Boolean)
        {
            Caption = 'Delete', Comment = 'ESP="Eliminar"';
            Description = 'Proyecto Alta Usuarios Navision';
        }
        field(10; COBCORUserCountry; Text[50])
        {
            CalcFormula = Lookup(COBCORWizUserConfigurationList.COBCORCountry WHERE(COBCORUserID = FIELD(COBCORUserID)));
            Caption = 'User Country', Comment = 'ESP="Pais Usuario"';
            Description = 'Proyecto Alta Usuarios Navision';
            FieldClass = FlowField;
        }
        field(11; COBCORGrantedByUser; Text[50])
        {
            Caption = 'Granted By User', Comment = 'ESP="Otorgado Por Usuario"';
        }
        field(12; COBCORGrantedDate; Date)
        {
            Caption = 'Granted Date', Comment = 'ESP="Fecha Otorgado"';
        }
        field(13; COBCORGrantedTime; Time)
        {
            Caption = 'Granted Time', Comment = 'ESP="Hora Otorgado"';
        }
        field(14; COBCORIsExtraRole; Boolean)
        {
            Caption = 'Extra Role', Comment = 'ESP="Rol Extra"';
            Editable = false;
        }
        field(15; COBCORIsDerivedRole; Boolean)
        {
            Caption = 'Derived Role', Comment = 'ESP="Rol Derivado"';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; COBCORUserID, COBCORCompanyName, COBCORCompanyRole)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}


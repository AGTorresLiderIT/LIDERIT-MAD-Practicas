table 50013 COBCORWizRoleExtraSetup
{
    Caption = 'Wizard Extra Role Setup', Comment = 'ESP="Configuración Roles Extra Wizard"';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    LookupPageId = COBCORWizRoleExtraSetup;
    DrillDownPageId = COBCORWizRoleExtraSetup;

    fields
    {
        field(1; COBCORRoleID; Code[20])
        {
            Caption = 'Role ID', Comment = 'ESP="ID Rol"';
        }
        field(2; COBCORExtraRoleID; Code[20])
        {
            Caption = 'Extra Role ID', Comment = 'ESP="ID Rol Extra"';
            TableRelation = "Aggregate Permission Set"."Role ID";
        }
        field(3; COBCORApplyInParent; Boolean)
        {
            Caption = 'Apply In Parent', Comment = 'ESP="Aplicar en Matriz"';
        }
        field(4; COBCORApplyInChild; Boolean)
        {
            Caption = 'Apply In Child', Comment = 'ESP="Aplicar en Hija"';
        }
    }

    keys
    {
        key(PK; COBCORRoleID, COBCORExtraRoleID)
        {
            Clustered = true;
        }
    }
}

table 50356 COBCORWizUserConfigDataHist
{
    Caption = 'Wizard User Role History', Comment = 'ESP="Histórico Roles Usuario Wizard"';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; COBCOREntryNo; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.', Comment = 'ESP="Nº Movimiento"';
        }
        field(2; COBCORUserID; Text[140])
        {
            Caption = 'User ID', Comment = 'ESP="ID Usuario"';
        }
        field(3; COBCORCompanyName; Text[30])
        {
            Caption = 'Company Name', Comment = 'ESP="Nombre Empresa"';
        }
        field(4; COBCORCompanyRole; Code[20])
        {
            Caption = 'Company Role', Comment = 'ESP="Rol Empresa"';
        }
        field(5; COBCORDelegation; Text[250])
        {
            Caption = 'Delegation', Comment = 'ESP="Delegación"';
        }
        field(6; COBCORAssignedRolesSIN; Boolean)
        {
            Caption = 'Assigned Roles SIN', Comment = 'ESP="Asignado Roles SIN"';
        }
        field(7; COBCORAssignedRolesFIL; Boolean)
        {
            Caption = 'Assigned Roles FIL', Comment = 'ESP="Asignado Roles FIL"';
        }
        field(8; COBCORDeactivatedAt; DateTime)
        {
            Caption = 'Deactivated At', Comment = 'ESP="FechaHora Baja"';
        }
        field(9; COBCORDeactivatedBy; Text[50])
        {
            Caption = 'Deactivated By', Comment = 'ESP="Usuario Baja"';
        }
        field(10; COBCORReactivatedAt; DateTime)
        {
            Caption = 'Reactivated At', Comment = 'ESP="FechaHora Reactivación"';
        }
        field(11; COBCORReactivatedBy; Text[50])
        {
            Caption = 'Reactivated By', Comment = 'ESP="Usuario Reactivación"';
        }
        field(12; COBCORIsDerivedRole; Boolean)
        {
            Caption = 'Derived Role', Comment = 'ESP="Rol Derivado"';
        }
    }

    keys
    {
        key(PK; COBCOREntryNo)
        {
            Clustered = true;
        }
        key(KeyUser; COBCORUserID, COBCORCompanyName, COBCORCompanyRole)
        {
        }
    }
}

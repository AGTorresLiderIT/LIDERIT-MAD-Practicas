table 50359 COBCORWizUsersBuffer
{
    Caption = 'COBCORWizUsersBuffer';
    DataClassification = ToBeClassified;
    TableType = Temporary;

    fields
    {
        field(1; COBCORCompanyName; Text[50])
        {
            Caption = 'COBCORCompanyName', Comment = 'ESP="Sociedad"';
        }
        field(2; COBCORCountry; Code[20])
        {
            Caption = 'COBCORCountry', Comment = 'ESP="País"';
        }
        field(3; COBCORUserID; Text[140])
        {
            Caption = 'COBCORUserID', Comment = 'ESP="ID Usuario"';
        }
        field(4; COBCORFullName; Text[100])
        {
            Caption = 'COBCORFullName', Comment = 'ESP="Nombre Completo"';
        }
        field(5; COBCORLicenseType; Text[50])
        {
            Caption = 'COBCORLicenseType', Comment = 'ESP="Tipo de Licencia"';
        }
        field(6; COBCORCompanyRole; Text[50])
        {
            Caption = 'COBCORCompanyRole', Comment = 'ESP="Rol Actual"';
        }
        field(7; COBCORDescriptionRole; Text[100])
        {
            Caption = 'COBCORDescriptionRole', Comment = 'ESP="Descripción Rol"';
        }
        field(8; COBCOROKRole; Text[100])
        {
            Caption = 'COBCOROKRole', Comment = 'ESP="Rol Correcto"';
        }
        field(9; COBCORCurrentDelegations; Code[20])
        {
            Caption = 'COBCORCurrentDelegations', Comment = 'ESP="Delegaciones Actuales"';
        }
        field(10; COBCOROKDelegations; Code[20])
        {
            Caption = 'COBCOROKDelegations', Comment = 'ESP="Delegaciones Correctas"';
        }
        field(11; COBCORCurrentSituation; Text[100])
        {
            Caption = 'COBCORCurrentSituation', Comment = 'ESP="Situación actual"';
        }
        field(12; COBCORCancelWizard; Boolean)
        {
            Caption = 'COBCORCancelWizard', Comment = 'ESP="Baja Wizard"';
        }
        field(13; COBCOREmail; Text[100])
        {
            Caption = 'COBCOREmail', Comment = 'ESP="Email"';
        }
        field(14; COBCOREsJefe; Boolean)
        {
            Caption = 'COBCOREsJefe', Comment = 'ESP="Es Jefe"';
        }
    }

    keys
    {
        key(PK; COBCORCompanyName, COBCORUserID, COBCORCompanyRole)
        {
            Clustered = true;
        }
    }
}
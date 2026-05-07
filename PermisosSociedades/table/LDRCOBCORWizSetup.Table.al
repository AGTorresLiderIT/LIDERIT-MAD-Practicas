table 50355 COBCORWizSetup
{
    Caption = 'Wizard Setup', Comment = 'ESP="Configuración Wizard"';
    DataClassification = CustomerContent;
    DataPerCompany = false;

    fields
    {
        field(1; COBCORPrimaryKey; Code[10])
        {
            Caption = 'Primary Key', Comment = 'ESP="Clave Primaria"';
        }
        field(2; COBCORNubeAllPermission; Code[20])
        {
            Caption = 'NUBE-ALL Permission', Comment = 'ESP="Permiso NUBE-ALL"';
            TableRelation = "Aggregate Permission Set"."Role ID";
        }
        field(3; COBCORReplicationTableNo; Integer)
        {
            Caption = 'Replication Table No.', Comment = 'ESP="Nº Tabla Replicación"';
            ToolTip = 'Indica el número de tabla para obtener las empresas desde replicación.', Comment = 'ESP="Indica el número de tabla para obtener las empresas desde replicación."';
        }
        field(4; COBCORDelegationDimension; Code[20])
        {
            Caption = 'Delegation Dimension', Comment = 'ESP="Dimensión Delegación"';
            ToolTip = 'Código de la dimensión que se usará como Delegación para los filtros de seguridad.', Comment = 'ESP="Código de la dimensión que se usará como Delegación para los filtros de seguridad."';
            TableRelation = "Dimension"."Code";
        }
        field(5; COBCORJefeContaPermission; Code[20])
        {
            Caption = 'JEFE-CONTAZONA Permission', Comment = 'ESP="Permiso JEFE CONTAZONA"';
            TableRelation = "Aggregate Permission Set"."Role ID";
        }
        field(6; COBCORWelcomeEmailUrl; Text[250])
        {
            Caption = 'Business Central URL', Comment = 'ESP="URL Business Central"';
            ToolTip = 'Specifies the Business Central URL included in welcome emails.', Comment = 'ESP="Especifica la URL de Business Central incluida en los correos de bienvenida."';
        }
        field(7; COBCORWelcomeManualESName; Text[100])
        {
            Caption = 'Spanish Manual Name', Comment = 'ESP="Nombre Manual Español"';
            ToolTip = 'Specifies the file name used for the Spanish welcome manual attachment.', Comment = 'ESP="Especifica el nombre de fichero usado para adjuntar el manual de bienvenida en español."';
        }
        field(8; COBCORWelcomeManualES; Blob)
        {
            Caption = 'Spanish Welcome Manual', Comment = 'ESP="Manual Bienvenida Español"';
            SubType = Memo;
        }
        field(9; COBCORWelcomeManualENName; Text[100])
        {
            Caption = 'English Manual Name', Comment = 'ESP="Nombre Manual Inglés"';
            ToolTip = 'Specifies the file name used for the English welcome manual attachment.', Comment = 'ESP="Especifica el nombre de fichero usado para adjuntar el manual de bienvenida en inglés."';
        }
        field(10; COBCORWelcomeManualEN; Blob)
        {
            Caption = 'English Welcome Manual', Comment = 'ESP="Manual Bienvenida Inglés"';
            SubType = Memo;
        }
    }

    keys
    {
        key(PK; COBCORPrimaryKey)
        {
            Clustered = true;
        }
    }
}

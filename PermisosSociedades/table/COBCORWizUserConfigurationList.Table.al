table 50358 COBCORWizUserConfigurationList
{
    Caption = 'Wizard User List', Comment = 'ESP="Wizard Lista Usuarios"';
    DataPerCompany = false;
    DrillDownPageID = COBCORWizUserConfigurationList;
    LookupPageID = COBCORWizUserConfigurationList;

    fields
    {
        field(1; COBCORUserID; Text[140])
        {
            Caption = 'User ID', Comment = 'ESP="ID Usuario"';
            Description = 'Proyecto Alta Usuarios Navision';
            NotBlank = true;
        }
        field(2; COBCORFullName; Text[150])
        {
            Caption = 'Full Name', Comment = 'ESP="Nombre completo"';
            Description = 'Nombre completo del usuario';
            NotBlank = true;
        }
        field(4; COBCOREmail; Text[100])
        {
            Caption = 'Email', Comment = 'ESP="Correo Electronico"';
            Description = 'Proyecto Alta Usuarios Navision';
            NotBlank = true;

        }
        field(5; COBCORDepartment; Code[30])
        {
            Caption = 'Department', Comment = 'ESP="Departamento"';
            Description = 'Proyecto Alta Usuarios Navision';
            NotBlank = true;
            TableRelation = COBCORWizDepartment.COBCORCode;
        }
        field(6; COBCORCountry; Text[50])
        {
            Caption = 'Country', Comment = 'ESP="Pais"';
            Description = '21/00072 Proyecto Alta Usuarios Navision';
            NotBlank = true;
            TableRelation = "Country/Region";
        }
        field(7; COBCORResponsible; Text[250])
        {
            Caption = 'Responsible', Comment = 'ESP="Responsable"';
            Description = 'Usuario que pidio el alta y por lo tanto es el responsable';
        }
        field(8; COBCORRegistrationDate; Date)
        {
            Caption = 'Registration Date', Comment = 'ESP="Fecha de Alta"';
            Description = 'Proyecto Alta Usuarios Navision';
        }
        field(9; COBCORMenu; Enum COBCORWizUserConfigMenu)
        {
            Caption = 'User Menu', Comment = 'ESP="Menu"';
            Description = 'Menu del usuario';
        }
        field(10; COBCORConnection; Enum COBCORWizUserConfigConnection)
        {
            Caption = 'Connection', Comment = 'ESP="Conexion"';
            Description = 'Base de datos o Windows';
            NotBlank = true;
        }
        field(11; COBCORDeactivated; Boolean)
        {
            Caption = 'Deactivated', Comment = 'ESP="Dado de Baja"';
            Description = 'Proyecto Alta Usuarios Navision';

            trigger OnValidate()
            begin
                IF COBCORDeactivated THEN
                    COBCORDeactivationDate := TODAY;

                IF NOT COBCORDeactivated THEN
                    COBCORDeactivationDate := 0D;
            end;
        }
        field(12; COBCORDeactivationDate; Date)
        {
            Caption = 'Deactivation Date', Comment = 'ESP="Fecha de Baja"';
            Description = 'Proyecto Alta Usuarios Navision';
        }
        field(13; COBCORBusinessGroup; code[20])
        {
            Caption = 'Business Group', Comment = 'ESP="Grupo Empresarial"';
        }
        field(14; COBCORLanguage; Enum COBCORWizUserConfigLanguage)
        {
            Caption = 'Language', Comment = 'ESP="Idioma"';
        }
        field(15; COBCORCountryName; Text[100])
        {
            Caption = 'Country Name', Comment = 'ESP="Nombre Pais"';
            CalcFormula = Lookup("Country/Region".Name WHERE(Code = FIELD(COBCORCountry)));
            Description = 'Calcula el nombre del código Pais';
            FieldClass = FlowField;
        }
        field(16; COBCORUnderReview; Boolean)
        {
            Caption = 'Under Review', Comment = 'ESP="En Revision"';
        }
        field(17; COBCORLicenseType; Enum COBCORWizUserConfigLicenseType)
        {
            Caption = 'License Type', Comment = 'ESP="Tipo de Licencias"';
            Description = 'Proyecto BC365';
        }
        field(18; COBCOREasyVistaRegistration; Code[30])
        {
            Caption = 'EasyVista Registration', Comment = 'ESP="EasyVista Alta"';
        }
        field(19; COBCOREasyVistaDeactivation; Code[30])
        {
            Caption = 'EasyVista Deactivation', Comment = 'ESP="EasyVista Baja"';
        }
        field(20; COBCORDeactivationResponsible; Text[250])
        {
            Caption = 'Deactivation Responsible', Comment = 'ESP="Responsable Baja"';
            Description = 'Responsable que gestionó la baja del usuario';
        }
    }

    keys
    {
        key(Key1; COBCORUserID)
        {
            Clustered = true;
        }
        key(Key2; COBCORRegistrationDate)
        {
        }
        key(Key3; COBCORCountry)
        {
        }
    }

    fieldgroups
    {
    }

    var

}


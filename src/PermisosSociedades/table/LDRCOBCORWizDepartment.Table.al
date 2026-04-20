table 50012 COBCORWizDepartment
{
    Caption = 'Wizard Departments', Comment = 'ESP="Departamentos Wizard"';
    DataClassification = CustomerContent;
    DataPerCompany = false;
    LookupPageId = COBCORWizDepartments;

    fields
    {
        field(1; COBCORCode; Code[30])
        {
            Caption = 'Department Code', Comment = 'ESP="Código Departamento"';
            NotBlank = true;
        }
        field(2; COBCORDescription; Text[100])
        {
            Caption = 'Department Description', Comment = 'ESP="Descripción Departamento"';
        }
        field(3; COBCORIsSupport; Boolean)
        {
            Caption = 'Support Department', Comment = 'ESP="Departamento Soporte"';
            ToolTip = 'Indica si el departamento es de soporte.', Comment = 'ESP="Indica si el departamento es de soporte."';
        }
    }

    keys
    {
        key(PK; COBCORCode)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; COBCORCode, COBCORDescription)
        {
        }
    }
}
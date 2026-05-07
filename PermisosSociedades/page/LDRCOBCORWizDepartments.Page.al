page 50353 COBCORWizDepartments
{
    ApplicationArea = All;
    Caption = 'COBCORWizDepartments', Comment = 'ESP="Departamentos Wizard"';
    PageType = List;
    SourceTable = COBCORWizDepartment;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(COBCORCode; Rec.COBCORCode)
                {
                    ToolTip = 'Specifies the value of the Department Code field.', Comment = '%ESP="Código Departamento"';
                }
                field(COBCORDescription; Rec.COBCORDescription)
                {
                    ToolTip = 'Specifies the value of the Department Description field.', Comment = '%ESP="Descripción Departamento"';
                }
                field(COBCORIsSupport; Rec.COBCORIsSupport)
                {
                    ToolTip = 'Indica si el departamento es de soporte.', Comment = '%ESP="Indica si el departamento es de soporte."';
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        g_recUserSetup.get(UserId);
    end;

    var
        g_recUserSetup: Record "User Setup";
}

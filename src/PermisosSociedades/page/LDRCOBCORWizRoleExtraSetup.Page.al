page 50034 COBCORWizRoleExtraSetup
{
    ApplicationArea = All;
    Caption = 'Wizard Extra Role Setup', Comment = 'ESP="Configuración Roles Extra Wizard"';
    PageType = List;
    SourceTable = COBCORWizRoleExtraSetup;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(COBCORRoleID; Rec.COBCORRoleID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the role that triggers extra permissions.', Comment = 'ESP="Especifica el rol que desencadena permisos extra"';
                }
                field(COBCORExtraRoleID; Rec.COBCORExtraRoleID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the extra role to assign when the main role is registered.', Comment = 'ESP="Especifica el rol extra a asignar al registrar el rol principal"';
                }
                field(COBCORApplyInParent; Rec.COBCORApplyInParent)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the extra role is applied in parent companies.', Comment = 'ESP="Especifica si el rol extra se aplica en empresas matriz"';
                }
                field(COBCORApplyInChild; Rec.COBCORApplyInChild)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the extra role is applied in child companies.', Comment = 'ESP="Especifica si el rol extra se aplica en empresas hijas"';
                }
            }
        }
    }
}

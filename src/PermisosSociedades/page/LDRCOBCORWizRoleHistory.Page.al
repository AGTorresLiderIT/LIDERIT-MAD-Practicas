page 50036 COBCORWizRoleHistory
{
    ApplicationArea = All;
    Caption = 'Wizard Role History', Comment = 'ESP="Histórico de Roles Wizard"';
    PageType = List;
    SourceTable = COBCORWizUserConfigDataHist;
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(COBCORUserID; Rec.COBCORUserID)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field.', Comment = 'ESP="ID Usuario"';
                }
                field(COBCORCompanyName; Rec.COBCORCompanyName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field.', Comment = 'ESP="Nombre Empresa"';
                }
                field(COBCORCompanyRole; Rec.COBCORCompanyRole)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Role field.', Comment = 'ESP="Rol Empresa"';
                }
                field(COBCORDelegation; Rec.COBCORDelegation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delegation field.', Comment = 'ESP="Delegación"';
                }
                field(COBCORDeactivatedAt; Rec.COBCORDeactivatedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deactivated At field.', Comment = 'ESP="FechaHora Baja"';
                }
                field(COBCORDeactivatedBy; Rec.COBCORDeactivatedBy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deactivated By field.', Comment = 'ESP="Usuario Baja"';
                }
                field(COBCORReactivatedAt; Rec.COBCORReactivatedAt)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reactivated At field.', Comment = 'ESP="FechaHora Reactivación"';
                }
                field(COBCORReactivatedBy; Rec.COBCORReactivatedBy)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reactivated By field.', Comment = 'ESP="Usuario Reactivación"';
                }
            }
        }
    }

    procedure SetUserFilter(pUserID: Text[140])
    begin
        Rec.Reset();
        Rec.SetRange(COBCORUserID, pUserID);
    end;
}

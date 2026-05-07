page 50351 COBCORWizAssignRolesSubform
{
    ApplicationArea = All;
    Caption = 'Wizard Assign Roles Subform', Comment = 'ESP="Subform Asignar Roles Wizard"';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = ListPart;
    SourceTable = COBCORWizUserConfigurationData;
    SourceTableView = sorting(COBCORUserID, COBCORCompanyName, COBCORCompanyRole);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(COBCORDelete; Rec.COBCORDelete)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether this role line is selected for deletion.', Comment = 'ESP="Eliminar"';
                }
                field(COBCORCompanyName; Rec.COBCORCompanyName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field.', Comment = 'ESP="Nombre Empresa"';
                    Editable = false;
                }
                field(COBCORCompanyRole; Rec.COBCORCompanyRole)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Role field.', Comment = 'ESP="Rol Empresa"';
                    Editable = false;
                }
                field(COBCORDelegation; Rec.COBCORDelegation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Delegation filter field.', Comment = 'ESP="Delegación"';
                    Editable = false;
                }
                field(COBCORGrantedByUser; Rec.COBCORGrantedByUser)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the user that granted the role.', Comment = 'ESP="Especifica el usuario que otorgó el rol"';
                    Editable = false;
                }
                field(COBCORGrantedDate; Rec.COBCORGrantedDate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when the role was granted.', Comment = 'ESP="Especifica la fecha en la que se otorgó el rol"';
                    Editable = false;
                }
                field(COBCORGrantedTime; Rec.COBCORGrantedTime)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time when the role was granted.', Comment = 'ESP="Especifica la hora en la que se otorgó el rol"';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(COBCORMarkAll)
            {
                ApplicationArea = All;
                Caption = 'Mark All', Comment = 'ESP="Marcar Todos"';
                Image = SelectEntries;
                ToolTip = 'Marks all role lines of the current user for deletion.', Comment = 'ESP="Marca para eliminar todas las líneas de roles del usuario actual"';

                trigger OnAction()
                begin
                    gCOBCORWizUsersMgt.MarkAllRolesForUser(Rec.COBCORUserID, true);

                    CurrPage.Update(false);
                end;
            }
            action(COBCORUnmarkAll)
            {
                ApplicationArea = All;
                Caption = 'Unmark All', Comment = 'ESP="Desmarcar Todos"';
                Image = ClearFilter;
                ToolTip = 'Unmarks all role lines of the current user.', Comment = 'ESP="Desmarca todas las líneas de roles del usuario actual"';

                trigger OnAction()
                begin
                    gCOBCORWizUsersMgt.MarkAllRolesForUser(Rec.COBCORUserID, false);

                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnModifyRecord(): Boolean
    begin
        if (Rec.COBCORCompanyName <> xRec.COBCORCompanyName) or
           (Rec.COBCORCompanyRole <> xRec.COBCORCompanyRole) or
           (Rec.COBCORDelegation <> xRec.COBCORDelegation)
        then
            Error(COBCORModifyCompanyRoleDelegationErrLbl);

        exit(true);
    end;

    procedure COBCORUpdateForm()
    begin
        CurrPage.Update(false);
    end;

    var
        COBCORModifyCompanyRoleDelegationErrLbl: Label 'You cannot modify Company Name/Company Role/Delegation from this page.', Comment = 'ESP="No puede modificar Nombre Empresa/Rol Empresa/Delegación desde este formulario"';
        gCOBCORWizUsersMgt: Codeunit COBCORWizUsersMgt;
}


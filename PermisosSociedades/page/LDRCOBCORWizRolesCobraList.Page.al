page 50365 COBCORWizRolesCobraList
{
    ApplicationArea = All;
    Caption = 'COBCORWizRolesCobraList', Comment = 'ESP="Lista Roles Cobra Wizard"';
    PageType = List;
    SourceTable = COBCORWizRolesCOBRAList;
    SourceTableView = SORTING("Permission Order") ORDER(descending);
    UsageCategory = Lists;


    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Role ID"; Rec."Role ID")
                {
                    ToolTip = 'Specifies the value of the Role ID field.', Comment = '%ESP="ID Rol"';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.', Comment = '%ESP="Nombre"';
                }
                field("Role abbreviation"; Rec."Role abbreviation")
                {
                    ToolTip = 'Specifies the value of the Role Abbreviation field.', Comment = '%ESP="Abreviatura Role"';
                }
                field("Permission Order"; Rec."Permission Order")
                {
                    ToolTip = 'Specifies the value of the Permission Order field.', Comment = '%ESP="Orden Permisos"';
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

pageextension 50200 "LDRUsers" extends "Users"
{
    actions
    {
        addafter("Update users from Office")
        {
            action("Desactivar Usuarios")
            {
                ApplicationArea = all;
                trigger OnAction()
                var
                    userTable: Record User;
                begin
                    CurrPage.SetSelectionFilter(userTable);

                    if UserTable.FindSet() then
                        UserTable.ModifyAll(State, UserTable.State::Disabled);
                end;
            }
        }
        addafter("Update users from Office_Promoted")
        {
            actionref("Desactivar Usuarios_Promoted"; "Desactivar Usuarios")
            {
            }
        }
    }
}

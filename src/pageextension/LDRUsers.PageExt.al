pageextension 50200 "LDRUsers" extends "Users"
{
    actions
    {
        addafter("Update users from Office")
        {
            action("Desactivar Usuarios")
            {
                ApplicationArea = all;
                ToolTip = 'Desactiva en el entorno los usuarios seleccionados';
                trigger OnAction()
                var
                    userTable: Record User;
                begin
                    CurrPage.SetSelectionFilter(userTable);

                    if UserTable.FindSet() then
                        UserTable.ModifyAll(State, UserTable.State::Disabled);
                end;
            }
            action("Activar Usuarios")
            {
                ApplicationArea = all;
                ToolTip = 'Activa en el entorno los usuarios seleccionados';
                trigger OnAction()
                var
                    userTable: Record User;
                begin
                    CurrPage.SetSelectionFilter(userTable);

                    if UserTable.FindSet() then
                        UserTable.ModifyAll(State, UserTable.State::Enabled);
                end;
            }
        }
        addafter("Update users from Office_Promoted")
        {
            actionref("Desactivar Usuarios_Promoted"; "Desactivar Usuarios")
            {
            }
            actionref("Activar Usuarios_Promoted"; "Activar Usuarios")
            {
            }
        }
    }
}

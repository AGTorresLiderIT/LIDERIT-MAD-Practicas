pageextension 50200 Companies extends Companies
{

    layout
    {
        addafter(EnableAssistedCompanySetup)
        {
            field(EnableEliminarAlCopiar; EnableEliminarAlCopiar)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Enable Eliminar Al Copiar';
                ToolTip = 'Specifies that the company will be eliminated in setting up the new enviroment.';

                trigger OnValidate()
                var
                    Eliminaralcopiar: Record "Eliminaralcopiar";
                begin
                    Eliminaralcopiar.SetEnabled(Rec.Name, EnableEliminarAlCopiar, false);
                end;
            }
        }

    }

    trigger OnAfterGetRecord()
    var
        Eliminaralcopiar: Record "Eliminaralcopiar";
    begin
        EnableEliminarAlCopiar := false;
        CurrPage.Editable;

        if not Eliminaralcopiar.Get(Rec.Name) then
            exit;

        EnableEliminarAlCopiar := Eliminaralcopiar.Enabled;
    end;

    var
        EnableEliminarAlCopiar: Boolean;
}

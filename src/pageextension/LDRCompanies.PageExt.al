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
    actions
    {
        addafter("Create New Company")
        {
            action(Encender)
            {
                Image = Percentage;
                ApplicationArea = all;
                trigger OnAction()
                var
                    configuracion: Record Configuracion;
                begin
                    if configuracion."Deshabilitar Usuarios" = false then begin
                        configuracion."Deshabilitar Usuarios" := true;
                        Message('La opción de seleccionar empresas al copiar está activada.')
                    end else begin
                        configuracion."Deshabilitar Usuarios" := false;
                        Message('La opción de seleccionar empresas al copiar está desactivada.')
                    end;
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

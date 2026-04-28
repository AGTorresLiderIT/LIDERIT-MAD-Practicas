page 50021 "Contraseña"
{
    ApplicationArea = All;
    Caption = 'Contraseña';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            field("Contraseña"; "Contraseña")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Contraseña field.', Comment = '%';
                Caption = 'Contraseña';
                ExtendedDatatype = Masked;
            }
        }
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        Mngt: Record ConfiguracionUtilidades;
    begin
        if CloseAction = Action::OK then begin
            if not Mngt.Get() then
                Error('No la configuración.');
            if "Contraseña" <> Mngt."Contraseña" then
                Error('Contraseña incorrecta')
        end;
    end;

    var
        Contraseña: Text[100];
}

page 50001 "ConfiguracionUtilidades"
{
    ApplicationArea = All;
    Caption = 'ConfiguracionUtilidades';
    PageType = Card;
    SourceTable = "ConfiguracionUtilidades";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Activar Borrado"; Rec."Activar Selección Empresa")
                {
                    ToolTip = 'Specifies the value of the Activar Selección Empresa field.', Comment = '%';
                }
                field("Activar Deshabilitar Usuarios"; Rec."Activar Deshabilitar Usuarios")
                {
                    ToolTip = 'Specifies the value of the Activar Deshabilitar Usuarios field.', Comment = '%';
                }
                field("Contraseña"; Rec."Contraseña")
                {
                    ToolTip = 'Specifies the value of the Contraseña field.', Comment = '%';
                    ExtendedDatatype = Masked;
                }
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}

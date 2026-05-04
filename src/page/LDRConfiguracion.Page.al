page 50209 Configuracion
{
    ApplicationArea = All;
    Caption = 'Configuracion';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = Configuracion;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Client ID"; Rec."Client ID")
                {
                    ToolTip = 'Specifies the value of the Client ID field.', Comment = '%';
                    Editable = true;
                }
                field("Client Secret"; Rec."Client Secret")
                {
                    ToolTip = 'Specifies the value of the Client Secret field.', Comment = '%';
                    Editable = true;
                }
                field("Deshabilitar Usuarios"; Rec."Deshabilitar Usuarios")
                {
                    ToolTip = 'Specifies the value of the Activar Deshabilitar Usuarios field.', Comment = '%';
                    Editable = true;
                }
                field(Scope; Rec.Scope)
                {
                    ToolTip = 'Specifies the value of the Scope field.', Comment = '%';
                    Editable = true;
                }
                field("Tenant ID"; Rec."Tenant ID")
                {
                    ToolTip = 'Specifies the value of the Tenant ID field.', Comment = '%';
                    Editable = true;
                }
            }
        }
    }
}

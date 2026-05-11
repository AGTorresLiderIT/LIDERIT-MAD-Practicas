page 50209 utilidadesLider
{
    ApplicationArea = All;
    Caption = 'Utilidades lider';
    PageType = Card;
    SourceTable = utilidadesLider;
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

                field("Deshabilitar Usuarios"; Rec."Deshabilitar Usuarios")
                {
                    ApplicationArea = All;
                    Caption = 'Deshabilitar Usuarios';
                    ToolTip = 'Activar Deshabilitar Usuarios';
                }

                field("Eliminar empresa al clonar"; Rec."Eliminar empresa al clonar")
                {
                    ApplicationArea = All;
                    Caption = 'Mantener empresas al clonar';
                    ToolTip = 'Activar mantener empresas al clonar';
                }

                field("Borrado de datos"; rec."Borrado de datos")
                {
                    ApplicationArea = All;
                    Caption = 'Activar borrado de datos';
                }

                field("Client ID"; Rec."Client ID")
                {
                    ApplicationArea = All;
                    Caption = 'ID del cliente de Azure entra ID';
                }

                field("Client Secret"; Rec."Client Secret")
                {
                    ApplicationArea = All;
                    Caption = 'Secreto del cliente';
                    ExtendedDatatype = Masked;
                }

                field("Tenant ID"; Rec."Tenant ID")
                {
                    ApplicationArea = All;
                    Caption = 'Id del tenant';
                    ToolTip = 'En la url desde el .com/ hasta /';
                }

                field("Scope"; Rec."Scope")
                {
                    ApplicationArea = All;
                    Caption = 'Scope para el token';
                    ToolTip = 'Scope para el token normalmente: https://api.businesscentral.dynamics.com/.default';
                }

                field("Mensaje Sandbox"; rec."Mensaje Sandbox")
                {
                    ApplicationArea = All;
                    Caption = 'Mensaje del sandbox';
                    ToolTip = 'Mensaje que sale al abrir una empresa en sandbox a quien no sea desarrollador';
                }

                field("Contraseña"; rec."contrasenaDet")
                {
                    ApplicationArea = All;
                    Caption = 'Contraseña';
                    ToolTip = 'Contraseña para entrar a distintas utilidades';
                    ExtendedDatatype = Masked;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Ir a configuracion borrar empresas")
            {
                Caption = 'Ir a configuracion mantener empresas';
                Image = View;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.RunModal(Page::MantenerEmpresas);
                end;
            }
            action("Ir a filtrado de datos al clonar")
            {
                Caption = 'Ir a filtrado de datos al clonar';
                Image = View;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.RunModal(Page::ReducirDatosTablas);
                end;
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

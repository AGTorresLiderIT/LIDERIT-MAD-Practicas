page 50209 utilidadesLider
{
    ApplicationArea = All;
    Caption = 'Utilidades lider';
    PageType = Card;
    SourceTable = utilidadesLider;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                Caption = 'General';

                field("Deshabilitar Usuarios"; Rec."Deshabilitar Usuarios")
                {
                    ApplicationArea = All;
                    Caption = 'Activar Deshabilitar Usuarios';
                }

                field("Eliminar empresa al clonar"; Rec."Eliminar empresa al clonar")
                {
                    ApplicationArea = All;
                    Caption = 'Activar eliminar empresas seleccionadas al clonar';
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
                    Caption = 'Id del tenant (en la url desde el .com/ hasta /)';
                }

                field("Scope"; Rec."Scope")
                {
                    ApplicationArea = All;
                    Caption = 'Scope para el token normalmente: https://api.businesscentral.dynamics.com/.default';
                }

                field("Mensaje Sandbox"; rec."Mensaje Sandbox")
                {
                    ApplicationArea = All;
                    Caption = 'Mensaje que sale al sabir una empresa en sandbox a quien no sea desarrollador';
                }

                field("Contraseña Data editor"; rec."contrasenaDet")
                {
                    ApplicationArea = All;
                    Caption = 'Contraseña para entrar al Data Editor Tool';
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
                Caption = 'Ir a configuracion borrar empresas';
                Image = View;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Page.RunModal(Page::"companies");
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
                    Page.RunModal(Page::"eliminarDatosFiltrados");
                end;
            }
        }
    }
}

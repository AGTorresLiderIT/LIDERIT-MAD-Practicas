page 50022 ReducirDatosTablas
{
    ApplicationArea = All;
    Caption = 'Reducir Datos';
    PageType = List;
    SourceTable = ReducirDatosTablas;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                Caption = 'General';
                field("ID Tabla"; Rec."ID Tabla")
                {
                    Caption = 'ID Tabla';
                    ApplicationArea = All;
                }
                field("Nombre Tabla"; Rec."Nombre Tabla")
                {
                    Caption = 'Nombre Tabla';
                    ApplicationArea = All;
                }
                field("ID Campo"; Rec."ID Campo")
                {
                    Caption = 'ID Campo Fecha';
                    ApplicationArea = All;
                }
                field("Filtro"; Rec."Filtro")
                {
                    Caption = 'Filtro';
                    ApplicationArea = All;
                }
                field("Activar"; Rec."Activar")
                {
                    Caption = 'Activar';
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Asignar Fecha")
            {
                ApplicationArea = All;
                Caption = 'Asignar Fecha';
                Image = Calendar;

                trigger OnAction()
                var
                    Conf: Record ConfigurarFecha;
                    ConfPage: Page ConfigurarFecha;
                begin
                    if not Conf.Get() then begin
                        Conf.Init();
                        Conf.FKey := '';
                        Conf.Insert();
                        Commit();
                    end;
                    ConfPage.SetRecord(Conf);
                    ConfPage.RunModal();
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        ContraseñaPage: Page Contraseña;
    begin
        if "ContraseñaPage".RunModal() <> Action::OK then
            Error('Acceso cancelado.');
    end;
}

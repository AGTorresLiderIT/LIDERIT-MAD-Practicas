page 50329 MantenerEmpresas
{
    ApplicationArea = All;
    Caption = 'MantenerEmpresas';
    PageType = List;
    SourceTable = MantenerEmpresas;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Nombre; Rec.Nombre)
                {
                    ToolTip = 'Specifies the value of the Nombre field.', Comment = '%';
                }
                field(Mantener; Rec.Mantener)
                {
                    ToolTip = 'Specifies the value of the Mantener field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Mantener todas las empresas")
            {
                Caption = 'Mantener todas las empresas';
                ToolTip = 'Pulsar para que aparezcan todas las empresas del entorno con el check de mantener activo.', Comment = '%';
                Image = View;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Empresas: Record Company;
                    Mantener: Record MantenerEmpresas;
                begin
                    if Empresas.FindSet() then
                        repeat
                            if not Mantener.Get(Empresas.Name) then begin
                                Mantener.Init();
                                Mantener.Nombre := Empresas.Name;
                                Mantener.Mantener := true;
                                Mantener.Insert();
                            end else begin
                                Mantener.Mantener := true;
                                Mantener.Modify();
                            end;
                        until Empresas.Next() = 0;

                    CurrPage.Update(false);

                    Message('Todas las empresas han sido añadidas y marcadas para mantener.');
                end;
            }
            action("No Mantener todas las empresas")
            {
                Caption = 'No Mantener todas las empresas';
                ToolTip = 'Desactivar todos los checks de mantener.', Comment = '%';
                Image = View;
                ApplicationArea = All;

                trigger OnAction()
                var
                    Mantener: Record MantenerEmpresas;
                begin
                    if Mantener.FindSet() then begin
                        Mantener.Reset();
                        Mantener.ModifyAll(Mantener, false);
                    end;
                    CurrPage.Update(false);

                    Message('Todas las empresas han sido marcadas para no mantenerse.');
                end;
            }
            action("Mantener empresas")
            {
                Caption = 'Mantener empresas';
                ToolTip = 'Pulsar para mantener las empresas seleccionadas.', Comment = '%';
                Image = View;
                ApplicationArea = All;

                trigger OnAction()
                var
                    RecSeleccionado: Record MantenerEmpresas;
                begin
                    CurrPage.SetSelectionFilter(RecSeleccionado);
                    if RecSeleccionado.FindSet() then
                        repeat
                            if not RecSeleccionado.Mantener then begin
                                RecSeleccionado.Mantener := true;
                                RecSeleccionado.Modify();
                            end;
                        until RecSeleccionado.Next() = 0;

                    CurrPage.Update(false);

                    Message('Las empresas seleccionadas han sido marcadas para mantenerse.');
                end;
            }
            action("No Mantener empresas")
            {
                Caption = 'No Mantener empresas';
                ToolTip = 'Pulsar para no mantener las empresas seleccionadas.', Comment = '%';
                Image = View;
                ApplicationArea = All;

                trigger OnAction()
                var
                    RecSeleccionado: Record MantenerEmpresas;
                begin
                    CurrPage.SetSelectionFilter(RecSeleccionado);
                    if RecSeleccionado.FindSet() then
                        repeat
                            if RecSeleccionado.Mantener then begin
                                RecSeleccionado.Mantener := false;
                                RecSeleccionado.Modify();
                            end;
                        until RecSeleccionado.Next() = 0;

                    CurrPage.Update(false);

                    Message('Las empresas seleccionadas han sido marcadas para no mantenerse.');
                end;
            }
        }
    }
    trigger OnOpenPage()
    var
        Empresas: Record Company;
        Mantener: Record MantenerEmpresas;
        MantenerBorrar: Record MantenerEmpresas;
        Utilidades: Record utilidadesLider;
    begin
        if Utilidades.FindFirst() then
            if not Utilidades."Eliminar empresa al clonar" then
                Error('La selección de empresas no está activada. Active la opción en "Utilidades lider".')
            else begin
                if Mantener.FindSet() then
                    repeat
                        if not Empresas.Get(Mantener.Nombre) then begin
                            MantenerBorrar.Get(Mantener.Nombre);
                            MantenerBorrar.Delete();
                        end;
                    until Mantener.Next() = 0;
                if Empresas.FindSet() then
                    repeat
                        if not Mantener.Get(Empresas.Name) then begin
                            Mantener.Init();
                            Mantener.Nombre := Empresas.Name;
                            Mantener.Mantener := false;
                            Mantener.Insert();
                        end;
                    until Empresas.Next() = 0
            end;
    end;
}

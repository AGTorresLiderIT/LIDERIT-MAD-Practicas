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
            action("Poner todas las empresas")
            {
                Caption = 'Poner todas las empresas en la tabla';
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

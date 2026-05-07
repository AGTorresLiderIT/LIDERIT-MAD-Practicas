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

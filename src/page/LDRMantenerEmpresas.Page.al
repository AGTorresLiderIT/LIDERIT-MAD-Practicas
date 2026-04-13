page 50149 MantenerEmpresas
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
    begin
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
}

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
    actions
    {
        area(Processing)
        {
            action(Encender)
            {
                trigger OnAction()
                var
                    Encendido: Boolean;
                begin
                    if Encendido = false then begin
                        Encendido := true;
                        Message('La opción de seleccionar empresas al copiar está activada.')
                    end else
                        Message('La opción de seleccionar empresas al copiar está desactivada.')
                end;
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

page 50322 ReducirDatosTablas
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
                    Caption = 'ID Campo';
                    ApplicationArea = All;
                    trigger onLookup(var Text: Text): Boolean
                    var
                        Field: Record Field;
                    begin
                        Field.SetRange(TableNo, Rec."ID Tabla");
                        if Page.RunModal(Page::"Fields Lookup", Field) = Action::LookupOK then
                            Rec."ID Campo" := Field."No.";
                    end;
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
}

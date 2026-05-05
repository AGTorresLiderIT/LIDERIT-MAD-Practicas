page 50207 eliminarDatosFiltrados
{
    PageType = List;
    SourceTable = "eliminarDatosFiltrados";
    ApplicationArea = All;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ApplicationArea = All;
                    TableRelation = Field."Field Caption" where(TableNo = field("Table ID"));
                }
                field("Filter Value"; Rec."Filter Value")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
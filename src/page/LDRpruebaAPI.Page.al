page 50209 pruebaAPI
{
    PageType = List;
    SourceTable = "Job Queue Request";
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Target Job Queue SystemId"; Rec."Target Job Queue SystemId") { }
                field(Action; Rec.Action) { }
                field(Status; Rec.Status) { }
            }
        }
    }
}
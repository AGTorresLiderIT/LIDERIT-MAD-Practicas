page 50208 "Job Queue Request API"

{
    PageType = API;
    APIPublisher = 'custom';
    APIGroup = 'automation';
    APIVersion = 'v1.0';
    EntityName = 'jobQueueRequest';
    EntitySetName = 'jobQueueRequests';

    DelayedInsert = true;

    SourceTable = "Job Queue Request";

    layout
    {
        area(content)
        {
            field(targetId; Rec."Target Job Queue SystemId") { }
            field(action; Rec.Action) { }
            field(status; Rec.Status) { }
        }
    }
}
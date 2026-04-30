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
        }
    }
    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin

        if not ProcessRequest(rec) then begin
            rec.Status := rec.Status::Error;
            rec."Error Message" := GetLastErrorText();
        end;
    end;


    [TryFunction]
    local procedure ProcessRequest(var Request: Record "Job Queue Request")
    var
        JobQueue: Record "Job Queue Entry";
    begin
        if not JobQueue.GetBySystemId(Request."Target Job Queue SystemId") then
            Error('Job Queue not found');

        case Request.Action of
            Request.Action::Start:
                begin
                    JobQueue.Restart();
                end;

            Request.Action::Stop:
                begin
                    JobQueue.CancelTask();
                end;

            Request.Action::Restart:
                begin
                    JobQueue.Restart();
                end;
        end;

        Request.Status := Request.Status::Processed;
        Request.Modify(true);
    end;
}
codeunit 50205 "LDRJob Queue Dispatcher"
{
    trigger OnRun()
    var
        Request: Record "Job Queue Request";
    begin
        Message('Dispatcher ejecutándose');
        Request.SetRange(Status, Request.Status::Pending);

        if Request.FindSet() then
            repeat
                if not ProcessRequest(Request) then begin
                    Request.Status := Request.Status::Error;
                    Request."Error Message" := GetLastErrorText();
                    Request.Modify(true);
                end;
            until Request.Next() = 0;
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
                    JobQueue.Status := JobQueue.Status::Ready;
                    JobQueue.Modify(true);
                end;

            Request.Action::Stop:
                begin
                    JobQueue.Status := JobQueue.Status::"On Hold";
                    JobQueue.Modify(true);
                end;

            Request.Action::Restart:
                begin
                    JobQueue.Status := JobQueue.Status::"On Hold";
                    JobQueue.Modify(true);

                    JobQueue.Status := JobQueue.Status::Ready;
                    JobQueue.Modify(true);
                end;
        end;

        Request.Status := Request.Status::Processed;
        Request.Modify(true);
    end;
}
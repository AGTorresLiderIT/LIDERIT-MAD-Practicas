codeunit 50207 "API Test Runner"
{
    trigger OnRun()
    var
        Request: Record "Job Queue Request";
        JobQueue: Record "Job Queue Entry";
    begin
        if JobQueue.FindFirst() then begin
            Request.Init();
            Request."Target Job Queue SystemId" := JobQueue.SystemId;
            Request.Action := Request.Action::Start;
            Request.Status := Request.Status::Pending;
            Request.Insert();

            Message('Request creado sin API externa');
        end;
    end;
}
pageextension 50201 "Job Queue Entries" extends "Job Queue Entries"
{
    layout
    {
        addLast(Control1)
        {
            field(SystemId; Rec.SystemId)
            {
                ApplicationArea = All;
                Caption = 'SystemId';
                ToolTip = 'GUID interno usado para integraciones y APIs.';
            }
        }
    }
    actions
    {
        addafter("Job &Queue")
        {
            action(startSelectedJob)
            {
                ApplicationArea = all;

                trigger OnAction()
                var
                    jobEntryTable: Record "Job Queue Entry";
                begin
                    CurrPage.SetSelectionFilter(jobEntryTable);

                    if jobEntryTable.FindSet() then begin
                        CallApi(jobEntryTable, 'Start');
                    end;
                end;
            }
            action(deleteSelectedJob)
            {
                ApplicationArea = all;

                trigger OnAction()
                var
                    jobEntryTable: Record "Job Queue Entry";
                begin
                    CurrPage.SetSelectionFilter(jobEntryTable);

                    if jobEntryTable.FindSet() then begin
                        CallApi(jobEntryTable, 'Stop');
                    end;
                end;
            }
            action(restartSelectedJob)
            {
                ApplicationArea = all;

                trigger OnAction()
                var
                    jobEntryTable: Record "Job Queue Entry";
                begin
                    CurrPage.SetSelectionFilter(jobEntryTable);

                    if jobEntryTable.FindSet() then begin
                        CallApi(jobEntryTable, 'Restart');
                    end;
                end;
            }
        }
    }

    procedure CallApi(jobEntryTable: Record "Job Queue Entry"; action: Text)
    var
        Setup: Record "utilidadesLider";
        EnvInfo: Codeunit "Environment Information";
        CompanyRec: Record Company;

        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;

        ContentHeaders: HttpHeaders;
        RequestHeaders: HttpHeaders;

        JsonBody: Text;
        Url: Text;
        Token: Text;

        ResponseText: Text;
    begin
        Setup.FindFirst();

        CompanyRec.Get(CompanyName());

        Url := 'https://api.businesscentral.dynamics.com/v2.0/' +
            Setup."Tenant ID" +
            '/' + EnvInfo.GetEnvironmentName() + '/api/custom/automation/v1.0/companies(' + DelChr(Format(CompanyRec.SystemId), '=', '{}') + ')/jobQueueRequests';


        Token := DelChr(GetAccessToken(), '=', '"');

        // JSON BODY

        JsonBody := '{' +
            '"targetId": "' + Format(jobEntryTable.SystemId) + '",' +
            '"action": "' + action + '"' +
        '}';

        Message('JSON Body: %1', JsonBody);


        // CONTENT

        Content.WriteFrom(JsonBody);

        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');



        // REQUEST

        Request.Method := 'POST';
        Request.SetRequestUri(Url);
        Request.Content := Content;


        Request.GetHeaders(RequestHeaders);

        RequestHeaders.Add('Authorization', 'Bearer ' + Token);

        // SEND

        Client.Send(Request, Response);

        Response.Content().ReadAs(ResponseText);


        if not Response.IsSuccessStatusCode() then
            Error('FAILED: %1 - %2', Response.HttpStatusCode(), ResponseText);
    end;

    procedure GetAccessToken(): Text
    var
        Setup: Record "utilidadesLider";
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
        ResponseText: Text;
        Body: Text;
        Headers: HttpHeaders;
        JObject: JsonObject;
        JsonToken: JsonToken;
        Token: Text;
    begin
        Setup.FindFirst();
        Body :=
            'client_id=' + Setup."Client ID" +
            '&scope=' + Setup.Scope +
            '&client_secret=' + Setup."Client Secret" +
            '&grant_type=client_credentials';

        Content.WriteFrom(Body);

        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/x-www-form-urlencoded');

        Client.Post(
            'https://login.microsoftonline.com/' + Setup."Tenant ID" + '/oauth2/v2.0/token',
            Content,
            Response
        );

        if Response.IsSuccessStatusCode() then begin
            Response.Content().ReadAs(ResponseText);
        end else begin
            Error('Error al obtener token: %1', Response.HttpStatusCode());
        end;
        // Leer respuesta JSON
        Response.Content().ReadAs(ResponseText);

        // Parsear JSON
        JObject.ReadFrom(ResponseText);

        JObject.Get('access_token', JsonToken);

        JsonToken.WriteTo(Token);
        exit(Token);
    end;
}

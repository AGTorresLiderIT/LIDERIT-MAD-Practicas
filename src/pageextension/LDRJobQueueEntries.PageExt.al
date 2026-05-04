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
            action(getacctoken)
            {
                ApplicationArea = all;

                trigger OnAction()
                var
                    jobEntryTable: Record "Job Queue Entry";
                begin
                    CurrPage.SetSelectionFilter(jobEntryTable);

                    if jobEntryTable.FindSet() then begin
                        GetAccessToken();
                        CallApi(jobEntryTable, 'Start');
                    end;
                end;
            }
        }//hay q borrar esto y poner el que getacctoken se ejecute cuando pidas hacer las req a la api y hacer los 3 botones quitar los messages y que se gurade el acctoken
    }

    procedure CallApi(jobEntryTable: Record "Job Queue Entry"; action: Text)
    var
        Setup: Record Configuracion;
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

        Message('URL: %1', Url);

        Token := DelChr(GetAccessToken(), '=', '"');

        // 🔴 DEBUG TOKEN (solo parte inicial por seguridad)
        if StrLen(Token) > 20 then
            Message('Token (preview): %1...', CopyStr(Token, 1, 20));

        // -------------------------
        // JSON BODY
        // -------------------------
        JsonBody := '{' +
            '"targetId": "' + Format(jobEntryTable.SystemId) + '",' +
            '"action": "' + action + '"' +
        '}';

        Message('JSON Body: %1', JsonBody);

        // -------------------------
        // CONTENT
        // -------------------------
        Content.WriteFrom(JsonBody);

        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');

        Message('Content-Type set');

        // -------------------------
        // REQUEST
        // -------------------------
        Request.Method := 'POST';
        Request.SetRequestUri(Url);
        Request.Content := Content;

        // AUTH HEADER
        Request.GetHeaders(RequestHeaders);

        Message('Adding Authorization header...');

        RequestHeaders.Add('Authorization', 'Bearer ' + Token);

        Message('Authorization header added');

        // -------------------------
        // SEND
        // -------------------------
        Client.Send(Request, Response);

        Message('Response received');

        Message('HTTP Status: %1', Response.HttpStatusCode());

        Response.Content().ReadAs(ResponseText);

        Message('Response body: %1', ResponseText);

        if Response.IsSuccessStatusCode() then
            Message('OK')
        else
            Error('FAILED: %1 - %2', Response.HttpStatusCode(), ResponseText);
    end;

    procedure GetAccessToken(): Text
    var
        Setup: Record Configuracion;
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
        setup.FindFirst();
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

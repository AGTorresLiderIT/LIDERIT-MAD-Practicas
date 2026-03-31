codeunit 50202 "LDR Simpsons API"
{
    procedure GetCharactersJson(): Text
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        JsonText: Text;
    begin
        if not HttpClient.Get('https://thesimpsonsapi.com/api/characters', Response) then
            Error('1');

        if not Response.IsSuccessStatusCode() then
            Error('Error HTTP %1: %2', Response.HttpStatusCode(), Response.ReasonPhrase());

        Response.Content().ReadAs(JsonText);
        exit(JsonText);
    end;

    procedure GetLocationJson(): Text
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        JsonText: Text;
    begin
        if not HttpClient.Get('https://thesimpsonsapi.com/api/locations', Response) then
            Error('1');

        if not Response.IsSuccessStatusCode() then
            Error('Error HTTP %1: %2', Response.HttpStatusCode(), Response.ReasonPhrase());

        Response.Content().ReadAs(JsonText);
        exit(JsonText);
    end;
}

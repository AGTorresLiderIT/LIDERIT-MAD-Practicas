codeunit 50202 "LDR Simpsons API"
{
    procedure GetCharactersJson(): Text
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        JsonText: Text;
    begin
        if not HttpClient.Get('https://thesimpsonsapi.com/api/characters', Response) then
            Error('Error en la llamada a la API');

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

    procedure GetLocationNumeroJson(LocationNumber: Integer): Text
    var
        HttpClient: HttpClient;
        Response: HttpResponseMessage;
        JsonText: Text;
        direccion: Text;
    begin
        direccion := StrSubstNo('https://thesimpsonsapi.com/api/locations/%1', LocationNumber);
        if not HttpClient.Get(direccion, Response) then
            Error('Error en la llamada a la API');

        if not Response.IsSuccessStatusCode() then
            Error('Error HTTP %1: %2', Response.HttpStatusCode(), Response.ReasonPhrase());

        Response.Content().ReadAs(JsonText);
        exit(JsonText);
    end;
}

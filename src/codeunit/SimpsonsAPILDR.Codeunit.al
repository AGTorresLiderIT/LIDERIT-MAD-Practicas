codeunit 54000 "SimpsonsAPI_LDR"
{
    procedure LlamarAPI(Var Json: JsonObject; BodyText: Text)
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ResponseText: Text;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;

    begin

        RequestMessage.Method('GET'); //Fijamos que vamos a hacer GET/POST/PATCH
        RequestMessage.SetRequestUri('https://thesimpsonsapi.com/api/characters'); //Url a la que vamos a llamar
        RequestMessage.GetHeaders(RequestHeaders); //Cargamos los headers
        RequestHeaders.Add('Accept', 'application/json'); //rellenamos los headers (Este es para poner que es json)
        Client.Timeout(30000); //Timeout

        Content.WriteFrom(BodyText);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Remove('Content-Type');
        ContentHeaders.Add('Content-Type', 'application/json');
        RequestMessage.Content := Content;


        if not Client.Send(RequestMessage, ResponseMessage) then //Envia la request y recibe el response
            Error('No se pudo conectar con la API.');//Si no es capaz de send debemos devolder error

        ResponseMessage.Content().ReadAs(ResponseText);
        //Lee el contenido del response y lo vuelca a una variable de texto

        if not ResponseMessage.IsSuccessStatusCode() then
            Error('Error %1 en %2 %3\Respuesta: %4', ResponseMessage.HttpStatusCode(), 'GET', 'https://thesimpsonsapi.com/api/characters', ResponseText);

        if not Json.ReadFrom(ResponseText) then
            Error('La respuesta de la API no es un JSON válido.');

    end;

}

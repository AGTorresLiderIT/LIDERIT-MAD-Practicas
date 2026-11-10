codeunit 52000 "Simpsons API_LDR"
{
    procedure BorrarPersonaje(Id: Integer; Nombre: Text; Age: Integer; Description: Text)
    var
        URLs: Record URLs_LDR;
        Obj: JsonObject;
        Json: JsonObject;
        Body: Text;
    begin
        URLs.FindFirst();

        Obj.Add('name', Nombre);
        Obj.Add('age', Age);
        Obj.Add('description', Description);
        Obj.WriteTo(Body);

        LlamarAPI(URLs.Enviar, '/Personajes/' + Format(Id), Json, 'DELETE', Body);
    end;

    procedure MoificarPersonaje(Id: Integer; Nombre: Text; Age: Integer; Description: Text)
    var
        URLs: Record URLs_LDR;
        Obj: JsonObject;
        Json: JsonObject;
        Body: Text;
    begin
        URLs.FindFirst();

        Obj.Add('name', Nombre);
        Obj.Add('age', Age);
        Obj.Add('description', Description);
        Obj.WriteTo(Body);

        LlamarAPI(URLs.Enviar, '/Personajes/' + Format(Id), Json, 'PATCH', Body);
    end;

    procedure EnviarPersonaje(Nombre: Text; Age: Integer; Description: Text)
    var
        URLs: Record URLs_LDR;
        Obj: JsonObject;
        Json: JsonObject;
        Body: Text;
    begin
        URLs.FindFirst();

        Obj.Add('name', Nombre);
        Obj.Add('age', Age);
        Obj.Add('description', Description);
        Obj.WriteTo(Body);

        LlamarAPI(URLs.Enviar, '/Personajes', Json, 'POST', Body);


    end;

    procedure EnviarFrases(Nombre: Text; Frases: JsonArray)
    var
        URLs: Record URLs_LDR;
        Obj: JsonObject;
        Json: JsonObject;
        Body: Text;
    begin
        URLs.FindFirst();

        Obj.Add('name', Nombre);
        Obj.Add('phrases', Frases);
        Obj.WriteTo(Body);

        LlamarAPI(URLs.Frases, '/Frases', Json, 'POST', Body);
    end;

    procedure LlamarAPI(Url: Text; EndPoint: Text; Var Json: JsonObject; Method: Text; BodyText: Text)
    var
        Client: HttpClient;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        RequestHeaders: HttpHeaders;
        ResponseText: Text;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;

    begin

        RequestMessage.Method(Method); //Fijamos que vamos a hacer GET/POST/PATCH
        RequestMessage.SetRequestUri(Url + EndPoint); //Url a la que vamos a llamar
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
            Error('Error %1 en %2 %3\Respuesta: %4', ResponseMessage.HttpStatusCode(), Method, Url + EndPoint, ResponseText);

        if not Json.ReadFrom(ResponseText) then
            Error('La respuesta de la API no es un JSON válido.');

    end;

    procedure CargarPersonajes()
    var
        Character: Record Characters_LDR;
        Resultados: JsonArray;
        Token: JsonToken;
        Json: JsonObject;
        Obj: JsonObject;
        Pagina: Integer;
        TotalPaginas: Integer;
        URLs: Record URLs_LDR;
    begin
        Pagina := 1;
        TotalPaginas := 1;
        URLs.FindFirst();

        repeat

            LlamarAPI(URLs.Recibir, '/characters?page=' + Format(Pagina), Json, 'GET', '');

            TotalPaginas := GetJsonInteger(Json, 'pages');
            Resultados := GetJsonArray(Json, 'results');

            foreach Token in Resultados do begin
                Obj := Token.AsObject();

                Character.Init();
                Character."ID Personaje" := GetJsonInteger(Obj, 'id');
                Character."Nombre Personaje" := CopyStr(GetJsonText(Obj, 'name'), 1, MaxStrLen(Character."Nombre Personaje"));
                Character."Fecha Actualizacion" := CurrentDateTime();
                Character.Insert();
            end;

            Pagina += 1;
        until Pagina > TotalPaginas;
    end;



    procedure ObtenerHabitante(IdPersonaje: Integer; var Age: Integer; var Description: Text; var Gender: Text; var Name: Text; var Occupation: Text; var PortraitPath: Text)
    var
        Json: JsonObject;
        URLs: Record URLs_LDR;

    begin
        URLs.FindFirst();


        LlamarAPI(URLs.Recibir, '/characters/' + Format(IdPersonaje), Json, 'GET', '');

        Age := GetJsonInteger(Json, 'age');
        Description := GetJsonText(Json, 'description');
        Gender := GetJsonText(Json, 'gender');
        Name := GetJsonText(Json, 'name');
        Occupation := GetJsonText(Json, 'occupation');
        PortraitPath := GetJsonText(Json, 'portrait_path');
    end;

    procedure Localizacion(IdLocalizacion: Integer; Var Name: Text; Var Image_Path: Text; Var Town: Text; Var Use: Text)
    var
        Json: JsonObject;
        URLs: Record URLs_LDR;

    begin
        URLs.FindFirst();


        LlamarAPI(URLs.Recibir, '/locations/' + Format(IdLocalizacion), Json, 'GET', '');

        Name := GetJsonText(Json, 'name');
        Image_Path := GetJsonText(Json, 'image_path');
        Town := GetJsonText(Json, 'town');
        Use := GetJsonText(Json, 'use');

    end;

    procedure ObtenerFrase(IdPersonaje: Integer): Text
    var
        Json: JsonObject;
        Frases: JsonArray;
        Token: JsonToken;
        URLs: Record URLs_LDR;

    begin
        URLs.FindFirst();


        LlamarAPI(URLs.Recibir, '/characters/' + Format(IdPersonaje), Json, 'GET', '');

        Frases := GetJsonArray(Json, 'phrases');
        if Frases.Count() = 0 then
            exit('');

        Frases.Get(Random(Frases.Count()) - 1, Token);
        exit(Token.AsValue().AsText());
    end;


    procedure ObtenerFrases(IdPersonaje: Integer; Var Frases: JsonArray)

    var
        Json: JsonObject;
        URLs: Record URLs_LDR;
    begin
        URLs.FindFirst();

        LlamarAPI(URLs.Recibir, '/characters/' + Format(IdPersonaje), Json, 'GET', '');

        Frases := GetJsonArray(Json, 'phrases');

    end;


    /// Lee una propiedad de texto. Devuelve '' si no existe o es null.
    local procedure GetJsonText(JsonObj: JsonObject; PropertyName: Text): Text
    var
        PropertyToken: JsonToken;
    begin
        if JsonObj.Get(PropertyName, PropertyToken) then
            if PropertyToken.IsValue() then
                if not PropertyToken.AsValue().IsNull() then
                    exit(PropertyToken.AsValue().AsText());
        exit('');
    end;

    /// Lee una propiedad numérica entera. Devuelve 0 si no existe o es null.
    local procedure GetJsonInteger(JsonObj: JsonObject; PropertyName: Text): Integer
    var
        PropertyToken: JsonToken;
    begin
        if JsonObj.Get(PropertyName, PropertyToken) then
            if PropertyToken.IsValue() then
                if not PropertyToken.AsValue().IsNull() then
                    exit(PropertyToken.AsValue().AsInteger());
        exit(0);
    end;

    /// Devuelve un objeto anidado. Si no existe, devuelve un JsonObject vacío (los Get posteriores dan '' / 0).
    local procedure GetJsonObject(JsonObj: JsonObject; PropertyName: Text) Result: JsonObject
    var
        PropertyToken: JsonToken;
    begin
        if JsonObj.Get(PropertyName, PropertyToken) then
            if PropertyToken.IsObject() then
                Result := PropertyToken.AsObject();
    end;

    /// Devuelve un array. Si no existe, devuelve un JsonArray vacío (Count = 0).
    local procedure GetJsonArray(JsonObj: JsonObject; PropertyName: Text) Result: JsonArray
    var
        PropertyToken: JsonToken;
    begin
        if JsonObj.Get(PropertyName, PropertyToken) then
            if PropertyToken.IsArray() then
                Result := PropertyToken.AsArray();
    end;


}

codeunit 50000 Simpsons_API
{
    procedure GetCharacters(var TablaCharacter: Record TemporalCharacters temporary; Persistente: Boolean)
    var
        ClienteHttp: HttpClient;
        RespuestaHttp: HttpResponseMessage;
        JsonRespuesta: Text;

        CharactersList: JsonObject;
        CharactersArray: JsonArray;
        Character: JsonToken;
        ObjetoCharacter: JsonObject;
        DatoToken: JsonToken;

        JsonArrayFrases: JsonArray;
        Frase: JsonToken;
        FrasesTexto: Text;

        TablaCharacters: Record Characters;
    begin
        if ClienteHttp.Get('https://thesimpsonsapi.com/api/characters', RespuestaHttp) then
            if RespuestaHttp.IsSuccessStatusCode() then begin
                RespuestaHttp.Content().ReadAs(JsonRespuesta);
                if CharactersList.ReadFrom(JsonRespuesta) then begin//ReadFrom() comprueba que la estructura del JSON es correcta
                    if CharactersList.Get('results', Character) then begin
                        CharactersArray := Character.AsArray();
                        foreach Character in CharactersArray do begin
                            ObjetoCharacter := Character.AsObject();
                            TablaCharacters.Init();
                            if ObjetoCharacter.Get('id', DatoToken) then begin
                                TablaCharacter.Init();
                                TablaCharacter.Id := DatoToken.AsValue().AsInteger();
                                if not TablaCharacters.Get(TablaCharacter.Id) then begin
                                    TablaCharacters.Init();
                                    TablaCharacters."ID Personaje" := TablaCharacter.Id;
                                end;
                                if ObjetoCharacter.Get('name', DatoToken) then begin
                                    TablaCharacters."Nombre Personaje" := DatoToken.AsValue().AsText();
                                    TablaCharacter.Nombre := DatoToken.AsValue().AsText();
                                end;
                                if ObjetoCharacter.Get('birthdate', DatoToken) then
                                    if not DatoToken.AsValue().IsNull() then
                                        Evaluate(TablaCharacter."Cumpleaños", DatoToken.AsValue().AsText());
                                if ObjetoCharacter.Get('age', DatoToken) then
                                    if not DatoToken.AsValue().IsNull() then
                                        Evaluate(TablaCharacter.Edad, DatoToken.AsValue().AsText());
                                if ObjetoCharacter.Get('gender', DatoToken) then
                                    TablaCharacter.Genero := DatoToken.AsValue().AsText();
                                if ObjetoCharacter.Get('occupation', DatoToken) then
                                    TablaCharacter.Puesto := DatoToken.AsValue().AsText();
                                if ObjetoCharacter.Get('phrases', DatoToken) then begin
                                    JsonArrayFrases := DatoToken.AsArray();
                                    FrasesTexto := '';
                                    foreach Frase in JsonArrayFrases do
                                        FrasesTexto += Frase.AsValue().AsText() + '.';
                                    TablaCharacter.Frases := FrasesTexto;
                                    TablaCharacters.Frases := FrasesTexto;
                                end;
                                if ObjetoCharacter.Get('portrait_path', DatoToken) then
                                    if not DatoToken.AsValue().IsNull() then
                                        TablaCharacter.Foto := 'https://cdn.thesimpsonsapi.com/500' + DatoToken.AsValue().AsText();
                                if Persistente then
                                    if not TablaCharacters.Modify(true) then
                                        TablaCharacters.Insert(true);
                                if not TablaCharacter.Insert() then;
                            end;
                        end;
                    end
                    else
                        Error('La API no ha devuelto un OK: %1', RespuestaHttp.HttpStatusCode());
                end
                else
                    Error('Error al conectarse a la API');
            end;
    end;

    /*procedure GetRandomLocation()
    var
        ClienteHttp: HttpClient;
        RespuestaHttp: HttpResponseMessage;
        JsonRespuesta: Text;

        LocationList: JsonObject;
        LocationArray: JsonArray;
        Location: JsonToken;
        ObjetoLista: JsonObject;
        DatoToken: JsonToken;

        RandomIndex: Integer;
        Localizacion: Text;
        Poblacion: Text;
    begin
        if ClienteHttp.Get('https://thesimpsonsapi.com/api/locations', RespuestaHttp) then
            if RespuestaHttp.IsSuccessStatusCode() then begin
                RespuestaHttp.Content().ReadAs(JsonRespuesta);
                if LocationList.ReadFrom(JsonRespuesta) then
                    if LocationList.Get('results', Location) then begin
                        LocationArray := Location.AsArray();
                        RandomIndex := Random(LocationArray.Count() - 1);
                        if LocationArray.Get(RandomIndex, Location) then begin
                            ObjetoLista := Location.AsObject();
                            if ObjetoLista.Get('name', DatoToken) then
                                Localizacion := DatoToken.AsValue().AsText();
                            if ObjetoLista.Get('town', DatoToken) then
                                Poblacion := DatoToken.AsValue().AsText();
                            Message('Smithers tiene que ir a pasear a los perros a %1 en %2', Localizacion, Poblacion);
                        end
                    end;
            end;
    end;*/
    procedure GetRandomLocation(var PaseoTemp: Record TemporalPaseo_de_perros temporary)
    var
        ClienteHttp: HttpClient;
        RespuestaHttp: HttpResponseMessage;
        JsonRespuesta: Text;

        LocationList: JsonObject;
        Location: JsonToken;
        RandomIndex: Integer;
        urlRandom: Text;
    begin
        if not PaseoTemp.Get(1) then exit;
        RandomIndex := Random(20);
        urlRandom := 'https://thesimpsonsapi.com/api/locations/' + Format(RandomIndex);
        if ClienteHttp.Get(urlRandom, RespuestaHttp) then
            if RespuestaHttp.IsSuccessStatusCode() then begin
                RespuestaHttp.Content().ReadAs(JsonRespuesta);
                if LocationList.ReadFrom(JsonRespuesta) then
                    if LocationList.Get('name', Location) then
                        PaseoTemp.Localizacion := Location.AsValue().AsText();
                if LocationList.Get('town', Location) then
                    PaseoTemp.Poblacion := Location.AsValue().AsText();
                PaseoTemp.Modify();
            end;
    end;
}

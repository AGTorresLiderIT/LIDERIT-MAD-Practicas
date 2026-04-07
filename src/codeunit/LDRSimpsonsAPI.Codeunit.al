codeunit 50000 Simpsons_API
{
    procedure GetCharacters()
    var
        ClienteHttp: HttpClient;
        RespuestaHttp: HttpResponseMessage;
        JsonRespuesta: Text;

        CharactersList: JsonObject;
        CharactersArray: JsonArray;
        Character: JsonToken;
        ObjetoCharacter: JsonObject;
        DatoToken: JsonToken;

        TablaCharacters: Record Characters;
    begin
        if ClienteHttp.Get('https://thesimpsonsapi.com/api/characters', RespuestaHttp) then begin
            if RespuestaHttp.IsSuccessStatusCode() then begin
                RespuestaHttp.Content().ReadAs(JsonRespuesta);
                if CharactersList.ReadFrom(JsonRespuesta) then begin//ReadFrom() comprueba que la estructura del JSON es correcta
                    if CharactersList.Get('results', Character) then begin
                        CharactersArray := Character.AsArray();
                        foreach Character in CharactersArray do begin
                            ObjetoCharacter := Character.AsObject();
                            TablaCharacters.Init();
                            if ObjetoCharacter.Get('id', DatoToken) then
                                TablaCharacters."ID Personaje" := DatoToken.AsValue.AsInteger();
                            if ObjetoCharacter.Get('name', DatoToken) then
                                TablaCharacters."Nombre Personaje" := DatoToken.AsValue.AsText();
                            if not TablaCharacters.Insert(true) then
                                TablaCharacters.Modify(true);
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
}

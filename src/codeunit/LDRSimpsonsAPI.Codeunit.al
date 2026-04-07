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
                            TablaCharacter.Init();
                            if ObjetoCharacter.Get('id', DatoToken) then begin
                                TablaCharacters."ID Personaje" := DatoToken.AsValue().AsInteger();
                                TablaCharacter.Id := DatoToken.AsValue().AsInteger();
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
                            end;
                            if ObjetoCharacter.Get('portrait_path', DatoToken) then
                                if not DatoToken.AsValue().IsNull() then
                                    TablaCharacter.Foto := 'https://cdn.thesimpsonsapi.com/500' + DatoToken.AsValue().AsText();
                            if Persistente then
                                if not TablaCharacters.Insert(true) then
                                    TablaCharacters.Modify(true);
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
}

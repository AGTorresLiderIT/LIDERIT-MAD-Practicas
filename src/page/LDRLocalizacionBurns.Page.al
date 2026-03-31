page 50202 LocalizacionBurns
{
    ApplicationArea = All;
    Caption = 'LocalizacionBurns';
    PageType = Card;

    layout
    {
        // area(Content)
        // {
        //     group(General)
        //     {
        //         field(Localizacion; localizacion)
        //         {
        //             ToolTip = 'Specifies the value of the Localizacion field.', Comment = '%';
        //         }

        //     }
        // }
    }
    actions
    {
        area(Processing)
        {
            action(GenerarLocalizacion)
            {
                ApplicationArea = All;
                Caption = 'GenerarLocalizacion';
                Image = Image;

                trigger OnAction()
                var
                    SimpsonsApi: Codeunit "LDR Simpsons API";
                    JsonText: Text;
                    JsonArray: JsonArray;
                    JsonObject: JsonObject;
                    ObjetoParaObtArrt: JsonToken;
                    ObjetoParaObtArr: JsonObject;
                    Pasointermedio: JsonToken;
                    JsonToken: JsonToken;
                    JsonTokenIt: JsonToken;

                    resultado: Text;
                    x: Integer;
                    ID: Integer;

                begin
                    JsonText := SimpsonsApi.GetLocationJson();

                    if not ObjetoParaObtArrt.ReadFrom(JsonText) then
                        Error('Error al analizar el JSON raíz.');

                    if not ObjetoParaObtArrt.IsObject() then
                        Error('1');

                    ObjetoParaObtArr := ObjetoParaObtArrt.AsObject();

                    // if not ObjetoParaObtArr.Get('pages', Pasointermedio) then
                    //     Error('No se encontró el campo count.');


                    // Pasointermedio.WriteTo(resultado);

                    Randomize();
                    // if not Evaluate(x, resultado) then
                    //     Error('Error al convertir el valor de count a entero.');
                    ID := Random(20) + 1;

                    if not ObjetoParaObtArr.Get('results', Pasointermedio) then
                        Error('No se encontró el array results.');

                    if not Pasointermedio.IsArray() then
                        Error('El token no es un array.')
                    else
                        JsonArray := Pasointermedio.AsArray();

                    foreach JsonTokenIt in JsonArray do begin

                        if not JsonTokenIt.IsObject() then
                            Error('2');

                        JsonObject := JsonTokenIt.AsObject();

                        if JsonObject.Get('id', JsonToken) then begin
                            JsonToken.WriteTo(resultado);
                            if not EVALUATE(x, resultado) then
                                Error('Error al convertir el ID del personaje.');
                        end;

                        if ID = x then begin
                            if JsonObject.Get('name', JsonToken) then begin
                                JsonToken.WriteTo(resultado);
                                Message('La localización a la que tiene que ir Burns es: %1', resultado);
                            end;
                            exit;
                        end;
                    end;
                end;
            }
        }
    }
}

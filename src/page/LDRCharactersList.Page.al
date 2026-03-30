page 50201 "LDRCharacters List"
{
    ApplicationArea = All;
    Caption = 'Characters List';
    PageType = List;
    SourceTable = LDRCharacters;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Nombre; Rec.Nombre)
                {
                    ToolTip = 'Specifies the value of the Nombre field.', Comment = '%';
                }
                field(Id; Rec.Id)
                {
                    ToolTip = 'Specifies the value of the Id field.', Comment = '%';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ObtenerCharacters)
            {
                Caption = 'ObtenerCharacters';
                Image = Refresh;
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
                    // i: Integer;
                    resultado: Text;
                    Character: Record LDRCharacters;
                begin
                    JsonText := SimpsonsApi.GetCharactersJson();
                    // Message('1');
                    if not ObjetoParaObtArrt.ReadFrom(JsonText) then
                        Error('Error al analizar el JSON raíz.');
                    // Message('2');
                    if not ObjetoParaObtArrt.IsObject() then
                        Error('1');
                    // Message('3');
                    ObjetoParaObtArr := ObjetoParaObtArrt.AsObject();
                    // Message('4');
                    if not ObjetoParaObtArr.Get('results', Pasointermedio) then
                        Error('No se encontró el array results.');
                    // Message('5');
                    if not Pasointermedio.IsArray() then
                        Error('El token no es un array.')
                    else
                        JsonArray := Pasointermedio.AsArray();
                    // Message('6');
                    // i := 6;
                    foreach JsonTokenIt in JsonArray do begin
                        // i += 1;
                        //Message('%1', i);
                        if not JsonTokenIt.IsObject() then
                            Error('2');

                        JsonObject := JsonTokenIt.AsObject();
                        Character.Init();
                        if JsonObject.Get('id', JsonToken) then begin
                            JsonToken.WriteTo(resultado);
                            if not EVALUATE(Character.Id, resultado) then
                                Error('Error al convertir el ID del personaje.');
                        end;

                        if JsonObject.Get('name', JsonToken) then
                            JsonToken.WriteTo(Character.Nombre);
                        Character.Insert();
                    end;
                end;
            }
        }
    }
}

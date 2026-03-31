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
                field(Ocupacion; Rec.Ocupacion)
                {
                    ToolTip = 'Specifies the value of the Ocupacion field.', Comment = '%';
                }
                field(FrasesCelebres; Rec.FrasesCelebres)
                {
                    ToolTip = 'Specifies the value of the FrasesCelebres field.', Comment = '%';
                }
                field(Localizacion; Rec.Localizacion)
                {
                    ToolTip = 'Specifies the value of the Localizacion field.', Comment = '%';
                }
            }

            usercontrol(ControlName; SampleAddIn)
            {
            }
        }
    }
    actions
    {
        area(Processing)
        {
            //Hecho con el array entero de la API, tambein se podría hacer llamando a la API por cada personaje
            action(ObtenerCharacters)
            {
                Caption = 'ObtenerCharacters';
                ToolTip = 'Descarga los personajes desde la API de Los Simpsons.';
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
                    resultado: Text;
                    Character: Record LDRCharacters;
                begin
                    Character.DeleteAll();
                    JsonText := SimpsonsApi.GetCharactersJson();

                    if not ObjetoParaObtArrt.ReadFrom(JsonText) then
                        Error('Error al analizar el JSON raíz.');

                    if not ObjetoParaObtArrt.IsObject() then
                        Error('1');

                    ObjetoParaObtArr := ObjetoParaObtArrt.AsObject();

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
                        Character.Init();
                        if JsonObject.Get('id', JsonToken) then begin
                            JsonToken.WriteTo(resultado);
                            if not EVALUATE(Character.Id, resultado) then
                                Error('Error al convertir el ID del personaje.');
                        end;

                        if JsonObject.Get('name', JsonToken) then
                            JsonToken.WriteTo(Character.Nombre);

                        if JsonObject.Get('occupation', JsonToken) then
                            JsonToken.WriteTo(Character.Ocupacion);

                        if JsonObject.Get('phrases', JsonToken) then
                            JsonToken.WriteTo(Character.FrasesCelebres);

                        if JsonObject.Get('location', JsonToken) then
                            JsonToken.WriteTo(Character.Localizacion);

                        Character.Insert();
                    end;
                end;
            }

            action(leerfrasesCelebres)
            {
                ApplicationArea = All;
                Caption = 'Leer frase célebre';

                trigger OnAction()
                begin
                    if Rec.FrasesCelebres <> '' then
                        CurrPage.ControlName.Speak(Rec.FrasesCelebres)
                    else
                        Message('No hay frase célebre seleccionada.');
                end;
            }
        }
    }
}

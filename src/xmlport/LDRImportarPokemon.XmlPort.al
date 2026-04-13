xmlport 50000 ImportarPokemon
{
    Caption = 'ImportarPokemon';
    Format = VariableText;
    TextEncoding = UTF8;
    Direction = Import;
    FieldSeparator = ';';
    UseRequestPage = false;
    Permissions = tabledata Pokemon = rmdi;
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(Integer; Integer)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                XmlName = 'Integer';
                // Columna 1
                textelement(columna1)    // Nombre del Pokémon
                {
                }
                textelement(columna2)    // Tipo del Pokémon
                {
                }
                textelement(columna3)    // Tamaño del Pokémon
                {
                }
                trigger OnBeforeInsertRecord()
                var
                    TamañosPokemon: Record "Tamaños Pokemon";
                    PokemonActual: Record Pokemon;
                    Existe: boolean;
                begin
                    contador += 1;
                    if PokemonActual.Get(columna1) then
                        Existe := true
                    else begin
                        PokemonActual.Init();
                        PokemonActual.Validate(Nombre, columna1);
                        Existe := false;
                    end;
                    if not Evaluate(PokemonActual.Tipo, columna2) then
                        Error('El tipo %1 no existe en la tabla de tamaños. (¡No hagas que Oak se enfade, busca el error en la línea %2!)', columna2, contador);
                    if TamañosPokemon.Get(columna3) then
                        PokemonActual.Validate(Tamañocm, TamañosPokemon."Tamañocm")
                    else
                        Error('El tamaño %1 no existe en la tabla de tamaños. (¡No hagas que Oak se enfade, busca el error en la línea %2!)', columna3, contador);
                    if Existe then
                        PokemonActual.Modify(true)
                    else
                        PokemonActual.Insert(true); //Así se actualiza respetando los campos existentes que no se especifican en el excel
                    // if not PokemonActual.Insert() then
                    //     PokemonActual.Modify();  Así se sobreescribe y deja a 0 los campos que no vengan en el excel
                end;
            }
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(Processing)
            {
            }
        }
    }
    var
        contador: Integer;

    trigger OnPostXmlPort()
    begin
        Message('¡Enhorabuena :)! Pokemon insertados: %1.', contador);
    end;
}

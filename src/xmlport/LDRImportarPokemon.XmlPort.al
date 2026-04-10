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
                    Pokemon: Record Pokemon;
                begin
                    contador += 1;
                    Pokemon.Init();
                    Pokemon.Validate(Nombre, columna1);
                    Evaluate(Pokemon.Tipo, columna2);
                    if TamañosPokemon.Get(columna3) then
                        Pokemon.Validate(Tamañocm, TamañosPokemon."Tamañocm")
                    else
                        Error('El tamaño %1 no existe en la tabla de tamaños. (¡No hagas que Oak se enfade, busca el error en la línea %2!)', columna3, contador);
                    Pokemon.Insert();
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

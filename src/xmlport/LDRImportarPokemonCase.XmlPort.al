xmlport 50001 ImportarPokemonCase
{
    Caption = 'ImportarPokemonCase';
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
            tableelement(Pokemon; Pokemon)
            {
                AutoReplace = false;
                AutoUpdate = true;
                AutoSave = true;
                // Columna 1
                fieldelement(Nombre; Pokemon.Nombre)    // Nombre del Pokémon
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
                begin
                    contador += 1;
                    columna2 := UPPERCASE(DelChr(columna2, '<>', ' '));
                    case columna2 of
                        'AGUA':
                            Pokemon.Tipo := Pokemon.Tipo::Agua;
                        'FUEGO':
                            Pokemon.Tipo := Pokemon.Tipo::Fuego;
                        'PLANTA':
                            Pokemon.Tipo := Pokemon.Tipo::Planta;
                        'ELÉCTRICO':
                            Pokemon.Tipo := Pokemon.Tipo::Electrico;
                        'NORMAL':
                            Pokemon.Tipo := Pokemon.Tipo::Normal;
                        'HADA':
                            Pokemon.Tipo := Pokemon.Tipo::Hada;
                        'LUCHA':
                            Pokemon.Tipo := Pokemon.Tipo::Lucha;
                        'PSÍQUICO':
                            Pokemon.Tipo := Pokemon.Tipo::Psiquico;
                        'VENENO':
                            Pokemon.Tipo := Pokemon.Tipo::Veneno;
                        'TIERRA':
                            Pokemon.Tipo := Pokemon.Tipo::Tierra;
                        'ROCA':
                            Pokemon.Tipo := Pokemon.Tipo::Roca;
                        'BICHO':
                            Pokemon.Tipo := Pokemon.Tipo::Bicho;
                        'DRAGÓN':
                            Pokemon.Tipo := Pokemon.Tipo::Dragon;
                        'ACERO':
                            Pokemon.Tipo := Pokemon.Tipo::Acero;
                        'FANTASMA':
                            Pokemon.Tipo := Pokemon.Tipo::Fantasma;
                        'HIELO':
                            Pokemon.Tipo := Pokemon.Tipo::Hielo;
                        'VOLADOR':
                            Pokemon.Tipo := Pokemon.Tipo::Volador;
                        'SINIESTRO':
                            Pokemon.Tipo := Pokemon.Tipo::Siniestro;
                        else
                            Error('El tipo %1 no es válido. (¡No hagas que Oak se enfade, busca el error en la línea %2!)', columna2, contador);
                    end;
                    if TamañosPokemon.Get(columna3) then
                        Pokemon.Validate(Tamañocm, TamañosPokemon."Tamañocm")
                    else
                        Error('El tamaño %1 no existe en la tabla de tamaños. (¡No hagas que Oak se enfade, busca el error en la línea %2!)', columna3, contador);
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

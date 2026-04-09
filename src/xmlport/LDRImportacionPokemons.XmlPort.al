xmlport 50200 ImportacionPokemons
{
    Caption = 'Importar Pokemons';
    Format = VariableText;
    TextEncoding = UTF8;
    Direction = Import;
    FieldSeparator = ';';
    UseRequestPage = false;
    Permissions = tabledata LDRPokemons = rmdi;
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

                textelement(Nombre)
                {
                }
                textelement(Tipo)
                {
                }
                textelement(tamanoletra)
                {
                }

                trigger OnBeforeInsertRecord()
                var
                    TablaTamano: Record LDRTamanos;
                    LDRPokemons: Record LDRPokemons;
                    LDRTipoPokemon: Enum "Tipo Pokemon";
                begin

                    case (tipo.ToLower()) of
                        'acero':
                            LDRTipoPokemon := LDRTipoPokemon::Acero;
                        'agua':
                            LDRTipoPokemon := LDRTipoPokemon::Agua;
                        'bicho':
                            LDRTipoPokemon := LDRTipoPokemon::Bicho;
                        'dragon':
                            LDRTipoPokemon := LDRTipoPokemon::Dragon;
                        'electrico':
                            LDRTipoPokemon := LDRTipoPokemon::Electrico;
                        'fantasma':
                            LDRTipoPokemon := LDRTipoPokemon::Fantasma;
                        'fuego':
                            LDRTipoPokemon := LDRTipoPokemon::Fuego;
                        'hada':
                            LDRTipoPokemon := LDRTipoPokemon::Hada;
                        'hielo':
                            LDRTipoPokemon := LDRTipoPokemon::Hielo;
                        'lucha':
                            LDRTipoPokemon := LDRTipoPokemon::Lucha;
                        'normal':
                            LDRTipoPokemon := LDRTipoPokemon::Normal;
                        'planta':
                            LDRTipoPokemon := LDRTipoPokemon::Planta;
                        'psiquico':
                            LDRTipoPokemon := LDRTipoPokemon::Psiquico;
                        'roca':
                            LDRTipoPokemon := LDRTipoPokemon::Roca;
                        'siniestro':
                            LDRTipoPokemon := LDRTipoPokemon::Siniestro;
                        'tierra':
                            LDRTipoPokemon := LDRTipoPokemon::Tierra;
                        'veneno':
                            LDRTipoPokemon := LDRTipoPokemon::Veneno;
                        'volador':
                            LDRTipoPokemon := LDRTipoPokemon::Volador;
                        else
                            Error('El tipo %1 no existe, revisa que no tenga tíldes', Tipo);
                    end;
                    LDRPokemons.Init();
                    LDRPokemons.Validate(tipo, LDRTipoPokemon);

                    LDRPokemons.Validate(Nombre, Nombre);

                    // Tamano por letra
                    TablaTamano.SetRange(Codigo, tamanoletra);
                    TablaTamano.FindSet();

                    if TablaTamano.IsEmpty then
                        Error('En la tabla Tamaño no existe esta medida, linea %1', NoLinea);

                    LDRPokemons.Validate("tamano", TablaTamano."Tamaño");
                    LDRPokemons.Insert();
                end;

                trigger OnAfterInsertRecord()
                begin
                    NoLinea := NoLinea + 1;
                end;

            }
            trigger OnAfterAssignVariable()
            begin
                NoLinea := 1;
            end;
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
        NoLinea: Integer;
}

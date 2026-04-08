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
}

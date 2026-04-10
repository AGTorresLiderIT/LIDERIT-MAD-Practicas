table 50000 Pokemon
{
    Caption = 'Pokemon';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Nombre; Text[50])
        {
            Caption = 'Nombre';
        }
        field(2; Tipo; Enum TiposPokemon)
        {
            Caption = 'Tipo';
        }
        field(3; Tamañocm; Decimal)
        {
            Caption = 'Tamañocm';
            trigger OnLookup()
            var
                TamañosPokemon: Record "Tamaños Pokemon";
                PaginaTamaños: Page "tamañospo";
            begin
                "PaginaTamaños".LookupMode(true);
                if "PaginaTamaños".RunModal() = Action::LookupOK then begin
                    "PaginaTamaños".GetRecord(TamañosPokemon);
                    Rec.Tamañocm := TamañosPokemon.Tamañocm;
                end;
            end;
        }
    }
    keys
    {
        key(PK; Nombre)
        {
            Clustered = true;
        }
    }
}

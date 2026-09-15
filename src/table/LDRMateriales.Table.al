table 50000 "LDR_Materiales"
{
    Caption = 'Materiales';
    DataClassification = ToBeClassified;
    LookupPageId = LDR_MaterialesList;

    fields
    {
        field(1; Codigo; Code[20])
        {
            Caption = 'Codigo';
        }
        field(2; Descripcion; Text[50])
        {
            Caption = 'Descripcion';
        }
        field(3; Bloqueado; Boolean)
        {
            Caption = 'Bloqueado';
        }
    }
    keys
    {
        key(PK; Codigo)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Codigo, Descripcion, Bloqueado)
        {
        }
    }
}

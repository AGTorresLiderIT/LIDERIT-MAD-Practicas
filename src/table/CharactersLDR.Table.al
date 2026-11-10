table 52000 "Characters_LDR"
{
    Caption = 'Characters';
    DataClassification = ToBeClassified;


    fields
    {
        field(1; "ID Personaje"; Integer)
        {
            Caption = 'ID Personaje';
            Editable = true;
        }
        field(2; "Nombre Personaje"; Text[100])
        {
            Caption = 'Nombre Personaje';
            Editable = true;

        }
        field(3; "Fecha Actualizacion"; DateTime)
        {
            Caption = 'Fecha Actualizacion';
            Editable = true;
        }
    }
    keys
    {
        key(PK; "ID Personaje")
        {
            Clustered = true;
        }
    }

    trigger OnModify()
    var
        SimpsonsAPI: Codeunit "Simpsons API_LDR";
        Age: Integer;
        Description: Text;
        Gender: Text;
        Name: Text;
        Occupation: Text;
        PortraitPath: Text;
    begin
        if Rec.IsTemporary() then
            exit;


        SimpsonsAPI.ObtenerHabitante(Rec."ID Personaje", Age, Description, Gender, Name, Occupation, PortraitPath);

        SimpsonsAPI.MoificarPersonaje(Rec."ID Personaje", Rec."Nombre Personaje", Age, Description);

        Message('Modificado: %1', Rec."Nombre Personaje");
    end;

}

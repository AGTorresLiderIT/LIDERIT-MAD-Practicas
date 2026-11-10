page 52000 "CharacterList_LDR"
{
    ApplicationArea = All;
    Caption = 'CharacterList';
    PageType = List;
    SourceTable = Characters_LDR;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ID Personaje"; Rec."ID Personaje")
                {
                    ToolTip = 'Specifies the value of the ID Personaje field.', Comment = '%';
                }
                field("Nombre Personaje"; Rec."Nombre Personaje")
                {
                    ToolTip = 'Specifies the value of the Nombre Personaje field.', Comment = '%';
                }
                field("Fecha Actualizacion"; Rec."Fecha Actualizacion")
                {
                    ToolTip = 'Specifies the value of the Fecha Actualizacion field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(CargarPersonajes)
            {
                ApplicationArea = All;
                Caption = 'Cargar Personajes', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Image;


                trigger OnAction()
                var
                    SimpsonsAPI: Codeunit "Simpsons API_LDR";
                begin
                    if not Rec.IsEmpty() then
                        if not Confirm('Ya hay personajes cargados, seguro que quieres recargar los datos?', false) then
                            exit;

                    Rec.DeleteAll();
                    SimpsonsAPI.CargarPersonajes();
                    CurrPage.Update();
                end;
            }

            action(EnviarPersonajeApi)
            {
                ApplicationArea = All;
                Caption = 'Enviar personajes', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Image;

                trigger OnAction()
                var
                    SimpsonsAPI: Codeunit "Simpsons API_LDR";
                    Age: Integer;
                    Description: Text;
                    Gender: Text;
                    Name: Text;
                    Occupation: Text;
                    PortraitPath: Text;
                begin
                    SimpsonsAPI.ObtenerHabitante(Rec."ID Personaje", Age, Description, Gender, Name, Occupation, PortraitPath);

                    SimpsonsAPI.EnviarPersonaje(Rec."Nombre Personaje", Age, Description);

                    Message('Enviado: %1', Rec."Nombre Personaje");
                end;
            }
            action(EnviarTodos)
            {
                ApplicationArea = All;
                Caption = 'Enviar TODOS los personajes', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Image;

                trigger OnAction()
                var
                    SimpsonsAPI: Codeunit "Simpsons API_LDR";
                    Age: Integer;
                    Description: Text;
                    Gender: Text;
                    Name: Text;
                    Occupation: Text;
                    PortraitPath: Text;
                    Bucle: Integer;
                begin
                    if Rec.FindSet() then
                        repeat
                            SimpsonsAPI.ObtenerHabitante(Rec."ID Personaje", Age, Description, Gender, Name, Occupation, PortraitPath);
                            SimpsonsAPI.EnviarPersonaje(Rec."Nombre Personaje", Age, Description);

                            Bucle += 1;
                        until (Rec.Next() = 0) or (Bucle = 100);
                    Message('Se han mandado %1 registros', Bucle);
                end;
            }
            action(BorrarPersonaje)
            {
                ApplicationArea = All;
                Caption = 'Borrar Personaje', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Image;

                trigger OnAction()
                var
                    SimpsonsAPI: Codeunit "Simpsons API_LDR";
                    Age: Integer;
                    Description: Text;
                    Gender: Text;
                    Name: Text;
                    Occupation: Text;
                    PortraitPath: Text;
                begin
                    SimpsonsAPI.ObtenerHabitante(Rec."ID Personaje", Age, Description, Gender, Name, Occupation, PortraitPath);

                    SimpsonsAPI.BorrarPersonaje(Rec."ID Personaje", Rec."Nombre Personaje", Age, Description);

                    Rec.Delete();

                    Message('Personaje: %1 Borrado', Rec."Nombre Personaje");


                end;

            }
            action(EnviarFrases)
            {
                ApplicationArea = All;
                Caption = 'Enviar TODAS las Frase', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Image;

                trigger OnAction()
                var
                    SimpsonsAPI: Codeunit "Simpsons API_LDR";
                    Bucle: Integer;
                    Frases: JsonArray;
                begin
                    if Rec.FindSet() then
                        repeat
                            SimpsonsAPI.ObtenerFrases(Rec."ID Personaje", Frases);

                            if Frases.Count() > 0 then begin
                                SimpsonsAPI.EnviarFrases(Rec."Nombre Personaje", Frases);
                                Bucle += 1;
                                Sleep(1000);
                            end;
                        until (Rec.Next() = 0) or (Bucle = 40);

                    Message('Se han mandado las frases de %1 personajes', Bucle);
                end;

            }
        }
    }
}

page 52001 "Habitantes de Springfield_LDR"
{
    ApplicationArea = All;
    Caption = 'Habitante de Springfield';
    PageType = Card;
    SourceTable = Characters_LDR;
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {


            group(Datos)
            {

                field("Nombre Personaje"; Rec."Nombre Personaje")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field(id; id)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(age; age)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(description; description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(gender; gender)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(name; name)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(ocupation; ocupation)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(portrait_path; portrait_path)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            usercontrol(Addin; "Simpsons Addin_LDR")
            {
                ApplicationArea = All;

                trigger Ready()
                begin
                    AddinListo := true;
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;
                Caption = 'Buscar por nombre', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Image;

                trigger OnAction()
                var
                    Characters: Record Characters_LDR;
                    SimpsonsAPI: Codeunit "Simpsons API_LDR";

                begin
                    Characters.SetRange("Nombre Personaje", Rec."Nombre Personaje");

                    if not Characters.FindFirst() then
                        Error('No se necontraron personajes');

                    id := Characters."ID Personaje";

                    SimpsonsAPI.ObtenerHabitante(id, age, description, gender, name, ocupation, portrait_path);
                    if AddinListo then
                        CurrPage.Addin.MostrarImagen('https://cdn.thesimpsonsapi.com/500' + portrait_path);

                    CurrPage.Update(false);

                end;
            }

            action(Reproducir)
            {
                ApplicationArea = All;
                Caption = 'Reproducir frase';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Start;

                trigger OnAction()
                var
                    SimpsonsAPI: Codeunit "Simpsons API_LDR";
                    Frase: Text;
                begin
                    if id = 0 then
                        Error('Primero busca un personaje.');

                    Frase := SimpsonsAPI.ObtenerFrase(id);
                    if Frase = '' then
                        Error('Este personaje no tiene frases.');

                    if AddinListo then
                        CurrPage.Addin.Hablar(Frase);
                end;
            }


        }

    }

    trigger OnOpenPage()
    begin
        Rec.Init();
        Rec."ID Personaje" := 1;
        Rec.Insert();
    end;




    var

        id: Integer;
        age: Integer;
        description: Text;
        gender: Text;
        name: Text;
        ocupation: Text;
        portrait_path: Text;
        AddinListo: Boolean;
}

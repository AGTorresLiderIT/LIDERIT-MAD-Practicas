page 52002 "Paseo de Perros_LDR"
{
    ApplicationArea = All;
    Caption = 'Paseo de Perros';
    PageType = Card;
    SourceTable = Locations_LDR;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {

            group(Datos)
            {
                field(id; id)
                {
                    ToolTip = 'Specifies the value of the id field.', Comment = '%';
                    Editable = false;
                }
                field(name; name)
                {
                    ToolTip = 'Specifies the value of the name field.', Comment = '%';
                    Editable = false;
                }
                field(image_path; image_path)
                {
                    ToolTip = 'Specifies the value of the image_path field.', Comment = '%';
                    Editable = false;
                }
                field(town; town)
                {
                    ToolTip = 'Specifies the value of the town field.', Comment = '%';
                    Editable = false;
                }
                field(use; use)
                {
                    ToolTip = 'Specifies the value of the use field.', Comment = '%';
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
                Caption = 'Localización al azar', comment = 'NLB="YourLanguageCaption"';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                Image = Image;

                trigger OnAction()
                var
                    SimpsonsAPI: Codeunit "Simpsons API_LDR";
                begin
                    id := Random(477);
                    SimpsonsAPI.Localizacion(id, name, image_path, town, use);

                    if AddinListo then
                        CurrPage.Addin.MostrarImagen('https://cdn.thesimpsonsapi.com/500' + image_path);

                    CurrPage.Update(false);
                end;
            }
        }


    }




    var
        AddinListo: Boolean;
        id: Integer;
        name: Text;
        image_path: Text;
        town: Text;
        use: Text;
}


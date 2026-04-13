page 50008 "App Deploy Error FactBox"
{
    PageType = CardPart;
    SourceTable = "App Deployment Staging";
    Caption = 'Detalles de Error de Implementación';

    layout
    {
        area(Content)
        {
            field("Error Message"; Rec."Error Message")
            {
                ApplicationArea = All;
                Caption = 'Mensaje de Error';
                ToolTip = 'Specifies any error message.';
                MultiLine = true;
                ShowCaption = false;
                StyleExpr = 'Unfavorable';
            }
        }
    }
}
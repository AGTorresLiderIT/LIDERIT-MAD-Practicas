page 50312 "DET Password Dialog"
{
    Caption = 'DET Password Dialog';
    PageType = StandardDialog;

    layout
    {
        area(Content)
        {
            field(Password; Password)
            {
                ApplicationArea = All;
                Caption = 'Password';
                ExtendedDatatype = Masked;
            }
        }
    }

    var
        Password: Text[50];

    procedure GetPassword(): Text
    begin
        exit(Password);
    end;
}

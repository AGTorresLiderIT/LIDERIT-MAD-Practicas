table 50000 "LDR_Customer Task"
{
    DataClassification = CustomerContent;


    fields
    {
        field(1; "Customer No."; Code[20])
        {
            caption = 'Customer No.', comment = 'ESP="Nº cliente"';
        }

        field(2; Description; Text[100])
        {
            Caption = 'Description', comment = 'ESP="Descripción"';
        }
    }
}

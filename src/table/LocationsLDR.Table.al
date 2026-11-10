table 52001 "Locations_LDR"
{
    Caption = 'Locations';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; id; Integer)
        {
            Caption = 'id';
        }
        field(2; name; Text[100])
        {
            Caption = 'name';
        }
        field(3; image_path; Text[100])
        {
            Caption = 'image_path';
        }
        field(4; town; Text[100])
        {
            Caption = 'town';
        }
        field(5; use; Text[100])
        {
            Caption = 'use';
        }
    }
    keys
    {
        key(PK; id)
        {
            Clustered = true;
        }
    }
}

table 50203 "Job Queue Request"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Entry No."; Integer) { AutoIncrement = true; }
        field(2; "Target Job Queue SystemId"; Guid) { }
        field(3; Action; Option)
        {
            OptionMembers = Start,Stop,Restart;
        }
        field(4; Status; Option)
        {
            OptionMembers = Pending,Processed,Error;
        }
        field(5; "Created At"; DateTime) { }
        field(6; "Error Message"; Text[250]) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}

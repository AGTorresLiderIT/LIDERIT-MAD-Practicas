enum 50000 "App Deployment Status"
{
    Extensible = true;

    value(0; Pending)
    {
        Caption = 'Pending';
    }
    value(1; "Waiting for Dependencies")
    {
        Caption = 'Waiting for Dependencies';
    }
    value(2; "Upload Started")
    {
        Caption = 'Upload Started';
    }
    value(3; "Upload Completed")
    {
        Caption = 'Upload Completed';
    }
    value(4; "Installation In Progress")
    {
        Caption = 'Installation In Progress';
    }
    value(5; Deployed)
    {
        Caption = 'Deployed';
    }
    value(6; Failed)
    {
        Caption = 'Failed';
    }
}
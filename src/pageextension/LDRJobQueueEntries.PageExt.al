pageextension 50201 "Job Queue Entries" extends "Job Queue Entries"
{
    layout
    {
        addLast(Control1)
        {
            field(SystemId; Rec.SystemId)
            {
                ApplicationArea = All;
                Caption = 'SystemId';
                ToolTip = 'GUID interno usado para integraciones y APIs.';
            }
        }
    }
}

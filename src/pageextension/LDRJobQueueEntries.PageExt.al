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
    actions
    {
        addlast(Processing)
        {
            action(TestAPI)
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    Test: Codeunit "API Test Runner";
                begin
                    Test.Run();
                end;
            }
        }
    }
}

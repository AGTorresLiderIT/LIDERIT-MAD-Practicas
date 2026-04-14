page 50200 "App Deployment Staging"
{
    PageType = List;
    SourceTable = "App Deployment Staging";
    Caption = 'App Deployment Scheduling';
    ApplicationArea = All;
    UsageCategory = Lists;
    CardPageId = "App Deployment Card";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number.';
                }
                field("App File Name"; Rec."App File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the app file name.';
                    StyleExpr = StatusStyleExpr;
                }
                field("File Deleted After Upload"; Rec."File Deleted After Upload")
                {
                    ApplicationArea = All;
                    ToolTip = 'File was deleted for security after upload';
                    Style = Attention;
                }
                field("File Hash"; Rec."File Hash")
                {
                    ApplicationArea = All;
                    ToolTip = 'SHA256 hash for file verification';
                    Visible = false;
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the app name from the operation.';
                }
                field("Scheduled Date"; Rec."Scheduled Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scheduled deployment date.';
                }
                field("Scheduled Time"; Rec."Scheduled Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scheduled deployment time.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the deployment status.';
                    StyleExpr = StatusStyleExpr;
                }
                field("Deployment Type"; Rec."Deployment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the deployment type.';
                }
                field("Send Email on Completion"; Rec."Send Email on Completion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to send email notification.';
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the entry was created.';
                }
                field("Deployed Date Time"; Rec."Deployed Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the app was deployed.';
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who created the entry.';
                }
            }
        }
        area(FactBoxes)
        {
            part(ErrorDetails; "App Deploy Error FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadAppFile)
            {
                Caption = 'Upload App File';
                Image = Import;
                ApplicationArea = All;
                ToolTip = 'Upload an app file for scheduled deployment.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    FileInStream: InStream;
                    FileName: Text;
                begin
                    if UploadIntoStream('Select App File', '', 'App Files (*.app)|*.app', FileName, FileInStream) then begin
                        Rec.SetAppFile(FileInStream, FileName);
                        Rec.Insert(true);
                        Message('App file uploaded successfully. Entry No. %1\n\nPlease set the schedule and email recipients.', Rec."Entry No.");
                    end;
                end;
            }
            action(DeployNow)
            {
                Caption = 'Deploy Now';
                Image = Start;
                ApplicationArea = All;
                ToolTip = 'Deploy the selected app immediately.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    if Rec.Status <> Rec.Status::Pending then
                        Error('Only pending deployments can be executed manually.');

                    if Rec."File Deleted After Upload" then
                        Error('App file has been deleted for security. Please re-upload the file using "Re-upload App File" action.');

                    if Confirm('Do you want to deploy this app now?', false) then begin
                        AppDeploymentMgt.DeployApp(Rec);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(ReuploadAppFile)
            {
                Caption = 'Re-upload App File';
                Image = Import;
                ApplicationArea = All;
                ToolTip = 'Re-upload the app file (if it was deleted for security)';
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec."File Deleted After Upload";

                trigger OnAction()
                var
                    FileInStream: InStream;
                    FileName: Text;
                begin
                    if not Rec."File Deleted After Upload" then
                        Error('File is still available. No need to re-upload.');

                    if UploadIntoStream('Select App File', '', 'App Files (*.app)|*.app', FileName, FileInStream) then begin
                        Rec.SetAppFile(FileInStream, FileName);
                        Rec.Modify(true);
                        Message('App file re-uploaded successfully. You can now deploy.');
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(RefreshStatus)
            {
                Caption = 'Refresh Status';
                Image = Refresh;
                ApplicationArea = All;
                ToolTip = 'Manually refresh the status of the selected deployment.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var

                begin
                    // AppDeploymentMgt.CheckOperationStatus(Rec);
                    CurrPage.Update(false);
                    Message('Status refreshed.');
                end;
            }
            action(ViewOperationDetails)
            {
                Caption = 'View in Extension Management';
                Image = View;
                ApplicationArea = All;
                ToolTip = 'Open Extension Management to view deployment details.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    AppDeploymentMgt.OpenExtensionManagement();
                end;
            }
            action(SetupJobQueue)
            {
                Caption = 'Setup Job Queue';
                Image = Setup;
                ApplicationArea = All;
                ToolTip = 'Setup the job queue for automatic deployment.';
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    AppDeploymentMgt.SetupJobQueue();
                end;
            }
            action(CreateDeploymentGroup)
            {
                Caption = 'Create Deployment Group';
                Image = NewDocument;
                ApplicationArea = All;
                ToolTip = 'Create a new deployment group for sequential app deployment';
                Promoted = true;
                PromotedCategory = New;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    GroupWizard: Page "Deployment Group Wizard";
                begin
                    GroupWizard.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(ViewDeploymentGroups)
            {
                Caption = 'Deployment Groups';
                Image = Group;
                ApplicationArea = All;
                ToolTip = 'View and manage deployment groups';
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    DeploymentGroups: Page "Deployment Groups";
                begin
                    DeploymentGroups.Run();
                end;
            }
            action(ViewExtensionManagement)
            {
                Caption = 'Extension Management';
                Image = Setup;
                ApplicationArea = All;
                ToolTip = 'Open Extension Management page to view all extensions and their status.';
                Promoted = true;
                PromotedCategory = Category4;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    AppDeploymentMgt.OpenExtensionManagement();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateStatusStyle();
    end;

    local procedure UpdateStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Deployed:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Failed:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::"Installation In Progress", Rec.Status::"Upload Started", Rec.Status::"Upload Completed":
                StatusStyleExpr := 'Ambiguous';
            else
                StatusStyleExpr := 'Standard';
        end;
    end;

    var
        StatusStyleExpr: Text;
}

page 50201 "App Deployment Card"
{
    PageType = Card;
    SourceTable = "App Deployment Staging";
    Caption = 'App Deployment Details';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number.';
                    Editable = false;
                }
                field("App File Name"; Rec."App File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the app file name.';
                    Editable = false;
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the app name.';
                    // Editable = false;
                    ShowMandatory = true;
                }
                field("Deployment Type"; Rec."Deployment Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the deployment type.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the deployment status.';
                    Editable = false;
                    StyleExpr = StatusStyleExpr;
                }
            }
            group(Schedule)
            {
                Caption = 'Schedule';

                field("Scheduled Date"; Rec."Scheduled Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scheduled deployment date.';
                }
                field("Scheduled Time"; Rec."Scheduled Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the scheduled deployment time.';
                }
            }
            group(EmailNotification)
            {
                Caption = 'Email Notification';

                field("Send Email on Completion"; Rec."Send Email on Completion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to send email notification when deployment completes.';
                }
                field("Email Recipients"; Rec."Email Recipients")
                {
                    ApplicationArea = All;
                    ToolTip = 'Semicolon-separated email addresses (e.g., user1@company.com;user2@company.com)';
                    MultiLine = true;
                }
            }
            group(Details)
            {
                Caption = 'Deployment Details';

                field("Operation ID"; Rec."Operation ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the operation ID from NAV App Tenant Operation.';
                    Editable = false;
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the entry was created.';
                    Editable = false;
                }
                field("Created By"; Rec."Created By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who created the entry.';
                    Editable = false;
                }
                field("Deployed Date Time"; Rec."Deployed Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the app was deployed or failed.';
                    Editable = false;
                }
                field("Last Status Check"; Rec."Last Status Check")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the status was last checked.';
                    Editable = false;
                }
            }
            group(ErrorInfo)
            {
                Caption = 'Error Information';
                Visible = ShowErrorInfo;

                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies any error message.';
                    Editable = false;
                    MultiLine = true;
                    StyleExpr = 'Unfavorable';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeployNow)
            {
                Caption = 'Deploy Now';
                Image = Start;
                ApplicationArea = All;
                ToolTip = 'Deploy the app immediately.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    if Rec.Status <> Rec.Status::Pending then
                        Error('Only pending deployments can be executed manually.');

                    if Confirm('Do you want to deploy this app now?', false) then begin
                        AppDeploymentMgt.DeployApp(Rec);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(RefreshStatus)
            {
                Caption = 'Refresh Status';
                Image = Refresh;
                ApplicationArea = All;
                ToolTip = 'Manually refresh the deployment status.';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.Update(false);
                    Message('Status refreshed.');
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateVisibility();
    end;

    local procedure UpdateVisibility()
    begin
        ShowErrorInfo := (Rec.Status = Rec.Status::Failed) and (Rec."Error Message" <> '');

        case Rec.Status of
            Rec.Status::Deployed:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Failed:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::"Installation In Progress", Rec.Status::"Upload Started", Rec.Status::"Upload Completed":
                StatusStyleExpr := 'Ambiguous';
            else
                StatusStyleExpr := 'Standard';
        end;
    end;

    var
        ShowErrorInfo: Boolean;
        StatusStyleExpr: Text;
}

page 50202 "App Deploy Error FactBox"
{
    PageType = CardPart;
    SourceTable = "App Deployment Staging";
    Caption = 'Error Details';

    layout
    {
        area(Content)
        {
            field("Error Message"; Rec."Error Message")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies any error message.';
                MultiLine = true;
                ShowCaption = false;
                StyleExpr = 'Unfavorable';
            }
        }
    }
}


// ========================================
// FILE: Page60003.DeploymentGroups.al
// ========================================

page 50203 "Deployment Groups"
{
    PageType = List;
    SourceTable = "App Deployment Staging";
    SourceTableView = sorting("Deployment Group", "Sequence No.");
    Caption = 'Deployment Groups';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Deployment Group"; Rec."Deployment Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Deployment group identifier';
                }
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Deployment sequence within the group';
                }
                field("App File Name"; Rec."App File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'App file name';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Current deployment status';
                    StyleExpr = StatusStyleExpr;
                }
                field("Depends On Entry No."; Rec."Depends On Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Entry number of dependent app';
                }
                field("Wait for Completion"; Rec."Wait for Completion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Wait for this app to complete before deploying next';
                }
                field("Scheduled Date"; Rec."Scheduled Date")
                {
                    ApplicationArea = All;
                }
                field("Scheduled Time"; Rec."Scheduled Time")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateNewGroup)
            {
                Caption = 'Create New Group';
                Image = NewDocument;
                ApplicationArea = All;
                ToolTip = 'Create a new deployment group';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    GroupWizard: Page "Deployment Group Wizard";
                begin
                    GroupWizard.RunModal();
                    CurrPage.Update(false);
                end;
            }
            action(DeployGroup)
            {
                Caption = 'Deploy Group Now';
                Image = Start;
                ApplicationArea = All;
                ToolTip = 'Deploy all apps in the selected group immediately';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    if Rec."Deployment Group" = '' then
                        Error('Please select a deployment group.');

                    if Confirm('Deploy all apps in group %1 now?', false, Rec."Deployment Group") then begin
                        AppDeploymentMgt.DeployGroup(Rec."Deployment Group");
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(ViewGroupDetails)
            {
                Caption = 'View Group Details';
                Image = View;
                ApplicationArea = All;
                ToolTip = 'View detailed information about the group';
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    GroupDetail: Page "Deployment Group Detail";
                begin
                    if Rec."Deployment Group" = '' then
                        Error('Please select a deployment group.');

                    GroupDetail.SetGroupCode(Rec."Deployment Group");
                    GroupDetail.RunModal();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateStatusStyle();
    end;

    local procedure UpdateStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Deployed:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Failed:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::"Installation In Progress", Rec.Status::"Upload Started",
            Rec.Status::"Upload Completed", Rec.Status::"Waiting for Dependencies":
                StatusStyleExpr := 'Ambiguous';
            else
                StatusStyleExpr := 'Standard';
        end;
    end;

    var
        StatusStyleExpr: Text;
}

// ========================================
// FILE: Page60004.DeploymentGroupWizard.al
// ========================================

page 50204 "Deployment Group Wizard"
{
    PageType = NavigatePage;
    Caption = 'Deployment Group Wizard';

    layout
    {
        area(Content)
        {
            group(Step1)
            {
                Caption = 'Step 1: Group Information';
                Visible = Step = 1;

                field(GroupCode; GroupCode)
                {
                    ApplicationArea = All;
                    Caption = 'Group Code';
                    ToolTip = 'Enter a unique code for this deployment group';
                }
                field(GroupScheduleDate; GroupScheduleDate)
                {
                    ApplicationArea = All;
                    Caption = 'Scheduled Date';
                    ToolTip = 'Date when the group should be deployed';
                }
                field(GroupScheduleTime; GroupScheduleTime)
                {
                    ApplicationArea = All;
                    Caption = 'Scheduled Time';
                    ToolTip = 'Time when the group should be deployed';
                }
                field(EmailRecipients; EmailRecipients)
                {
                    ApplicationArea = All;
                    Caption = 'Email Recipients';
                    ToolTip = 'Semicolon-separated email addresses';
                    MultiLine = true;
                }
            }
            group(Step2)
            {
                Caption = 'Step 2: Upload Apps';
                Visible = Step = 2;

                field(AppCountInfo; StrSubstNo('Apps uploaded: %1', TempEntryNumbers.Count))
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    Style = Strong;
                }
                group(UploadInstructions)
                {
                    Caption = 'Instructions';
                    field(Instructions; 'Upload apps in the order they should be deployed. First app will be sequence 1, second will be sequence 2, etc.')
                    {
                        ApplicationArea = All;
                        ShowCaption = false;
                        Editable = false;
                        MultiLine = true;
                    }
                }
            }
            group(Step3)
            {
                Caption = 'Step 3: Review';
                Visible = Step = 3;

                field(ReviewInfo; GetReviewInfo())
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    MultiLine = true;
                    Style = Strong;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UploadApp)
            {
                Caption = 'Upload App';
                Image = Import;
                ApplicationArea = All;
                Visible = Step = 2;
                InFooterBar = true;
                trigger OnAction()
                var
                    AppDeploymentStaging: Record "App Deployment Staging";
                    FileInStream: InStream;
                    FileName: Text;
                begin
                    if UploadIntoStream('Select App File', '', 'App Files (*.app)|*.app', FileName, FileInStream) then begin
                        // Create the actual staging record immediately (not temporary)
                        AppDeploymentStaging.Init();
                        AppDeploymentStaging."Deployment Group" := GroupCode;
                        AppDeploymentStaging."Sequence No." := GetNextSequenceNo();
                        AppDeploymentStaging."Scheduled Date" := GroupScheduleDate;
                        AppDeploymentStaging."Scheduled Time" := GroupScheduleTime;
                        AppDeploymentStaging."Email Recipients" := EmailRecipients;
                        AppDeploymentStaging."Wait for Completion" := true;
                        AppDeploymentStaging.Insert(true);
                        AppDeploymentStaging.SetAppFile(FileInStream, FileName);
                        AppDeploymentStaging.Modify();

                        // Store entry number for dependency chain
                        TempEntryNumbers."Entry No." := AppDeploymentStaging."Entry No.";
                        TempEntryNumbers.Insert();

                        Message('App uploaded: %1 (Sequence %2)', FileName, AppDeploymentStaging."Sequence No.");
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(RemoveLast)
            {
                Caption = 'Remove Last';
                Image = Delete;
                ApplicationArea = All;
                Visible = Step = 2;
                InFooterBar = true;
                trigger OnAction()
                var
                    AppDeploymentStaging: Record "App Deployment Staging";
                begin
                    if not TempEntryNumbers.FindLast() then
                        exit;

                    if AppDeploymentStaging.Get(TempEntryNumbers."Entry No.") then
                        AppDeploymentStaging.Delete(true);

                    TempEntryNumbers.Delete();
                    Message('Last app removed.');
                    CurrPage.Update(false);
                end;
            }
            action(NextStep)
            {
                Caption = 'Next';
                Image = NextRecord;
                ApplicationArea = All;
                Visible = Step < 3;
                InFooterBar = true;
                trigger OnAction()
                begin
                    if Step = 1 then begin
                        if GroupCode = '' then
                            Error('Please enter a group code.');
                        if GroupScheduleDate = 0D then
                            Error('Please enter a scheduled date.');
                        if GroupScheduleTime = 0T then
                            Error('Please enter a scheduled time.');
                    end;

                    if Step = 2 then begin
                        if TempEntryNumbers.Count = 0 then
                            Error('Please upload at least one app.');
                    end;

                    Step += 1;
                    CurrPage.Update(false);
                end;
            }
            action(PrevStep)
            {
                Caption = 'Previous';
                Image = PreviousRecord;
                ApplicationArea = All;
                Visible = Step > 1;
                InFooterBar = true;
                trigger OnAction()
                begin
                    Step -= 1;
                    CurrPage.Update(false);
                end;
            }
            action(Finish)
            {
                Caption = 'Finish & Create Dependencies';
                Image = Approve;
                ApplicationArea = All;
                Visible = Step = 3;
                InFooterBar = true;
                trigger OnAction()
                begin
                    CreateDependencyChain();
                    Message('Deployment group %1 created successfully with %2 apps.', GroupCode, TempEntryNumbers.Count);
                    CurrPage.Close();
                end;
            }
        }
    }

    local procedure CreateDependencyChain()
    var
        AppDeploymentStaging: Record "App Deployment Staging";
        PreviousEntryNo: Integer;
    begin
        // Update all records to link dependencies
        if TempEntryNumbers.FindSet() then begin
            repeat
                if AppDeploymentStaging.Get(TempEntryNumbers."Entry No.") then begin
                    if PreviousEntryNo <> 0 then begin
                        AppDeploymentStaging."Depends On Entry No." := PreviousEntryNo;
                        AppDeploymentStaging.Modify(true);
                    end;
                    PreviousEntryNo := TempEntryNumbers."Entry No.";
                end;
            until TempEntryNumbers.Next() = 0;
        end;
    end;

    local procedure GetNextSequenceNo(): Integer
    var
        AppDeploymentStaging: Record "App Deployment Staging";
    begin
        AppDeploymentStaging.SetRange("Deployment Group", GroupCode);
        if AppDeploymentStaging.FindLast() then
            exit(AppDeploymentStaging."Sequence No." + 1);
        exit(1);
    end;

    local procedure GetReviewInfo(): Text
    var
        AppDeploymentStaging: Record "App Deployment Staging";
        Info: Text;
    begin
        Info := 'Group Code: ' + GroupCode + '\';
        Info += 'Schedule: ' + Format(GroupScheduleDate) + ' ' + Format(GroupScheduleTime) + '\';
        Info += 'Total Apps: ' + Format(TempEntryNumbers.Count) + '\';
        Info += 'Email Recipients: ' + EmailRecipients + '\\';
        Info += 'Apps will be deployed in sequence:\';

        AppDeploymentStaging.SetRange("Deployment Group", GroupCode);
        AppDeploymentStaging.SetCurrentKey("Deployment Group", "Sequence No.");
        if AppDeploymentStaging.FindSet() then
            repeat
                Info += Format(AppDeploymentStaging."Sequence No.") + '. ' + AppDeploymentStaging."App File Name" + '\';
            until AppDeploymentStaging.Next() = 0;

        exit(Info);
    end;

    var
        TempEntryNumbers: Record "App Deployment Staging" temporary;
        GroupCode: Code[20];
        GroupScheduleDate: Date;
        GroupScheduleTime: Time;
        EmailRecipients: Text[250];
        Step: Integer;

    trigger OnOpenPage()
    begin
        Step := 1;
        GroupScheduleDate := Today;
        GroupScheduleTime := Time;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        AppDeploymentStaging: Record "App Deployment Staging";
    begin
        // If user cancels, delete any created records
        if CloseAction = CloseAction::Cancel then begin
            if Confirm('Do you want to delete the uploaded apps?', true) then begin
                AppDeploymentStaging.SetRange("Deployment Group", GroupCode);
                AppDeploymentStaging.DeleteAll(true);
            end;
        end;
        exit(true);
    end;// =======================================
}

// ========================================
// FILE: Page60005.DeploymentGroupDetail.al
// ========================================

page 50205 "Deployment Group Detail"
{
    PageType = Card;
    Caption = 'Deployment Group Details';
    SourceTable = "App Deployment Staging";
    SourceTableView = sorting("Deployment Group", "Sequence No.");

    layout
    {
        area(Content)
        {
            group(GroupInfo)
            {
                Caption = 'Group Information';

                field("Deployment Group"; GroupCode)
                {
                    ApplicationArea = All;
                    Caption = 'Group Code';
                    Editable = false;
                }
                field(TotalApps; TotalApps)
                {
                    ApplicationArea = All;
                    Caption = 'Total Apps';
                    Editable = false;
                }
                field(CompletedApps; CompletedApps)
                {
                    ApplicationArea = All;
                    Caption = 'Completed';
                    Editable = false;
                    Style = Favorable;
                }
                field(FailedApps; FailedApps)
                {
                    ApplicationArea = All;
                    Caption = 'Failed';
                    Editable = false;
                    Style = Unfavorable;
                }
                field(PendingApps; PendingApps)
                {
                    ApplicationArea = All;
                    Caption = 'Pending';
                    Editable = false;
                }
            }
            part(AppsList; "Deployment Group Apps")
            {
                ApplicationArea = All;
                SubPageLink = "Deployment Group" = field("Deployment Group");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(DeployGroup)
            {
                Caption = 'Deploy Group Now';
                Image = Start;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    AppDeploymentMgt: Codeunit "App Deployment Management";
                begin
                    if Confirm('Deploy all apps in this group now?', false) then begin
                        AppDeploymentMgt.DeployGroup(GroupCode);
                        CurrPage.Update(false);
                    end;
                end;
            }
            action(RefreshStatus)
            {
                Caption = 'Refresh Status';
                Image = Refresh;
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    UpdateStatistics();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    procedure SetGroupCode(NewGroupCode: Code[20])
    begin
        GroupCode := NewGroupCode;
        Rec.SetRange("Deployment Group", GroupCode);
        if Rec.FindFirst() then;
        UpdateStatistics();
    end;

    local procedure UpdateStatistics()
    var
        AppDeployment: Record "App Deployment Staging";
    begin
        AppDeployment.SetRange("Deployment Group", GroupCode);
        TotalApps := AppDeployment.Count();

        AppDeployment.SetRange(Status, AppDeployment.Status::Deployed);
        CompletedApps := AppDeployment.Count();

        AppDeployment.SetRange(Status, AppDeployment.Status::Failed);
        FailedApps := AppDeployment.Count();

        AppDeployment.SetRange(Status, AppDeployment.Status::Pending);
        PendingApps := AppDeployment.Count();
    end;

    var
        GroupCode: Code[20];
        TotalApps: Integer;
        CompletedApps: Integer;
        FailedApps: Integer;
        PendingApps: Integer;

    trigger OnAfterGetRecord()
    begin
        UpdateStatistics();
    end;
}

// ========================================
// FILE: Page60006.DeploymentGroupApps.al
// ========================================

page 50206 "Deployment Group Apps"
{
    PageType = ListPart;
    SourceTable = "App Deployment Staging";
    SourceTableView = sorting("Deployment Group", "Sequence No.");
    Caption = 'Apps in Group';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Sequence No."; Rec."Sequence No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Deployment sequence';
                    StyleExpr = StatusStyleExpr;
                }
                field("App File Name"; Rec."App File Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'App file name';
                }
                field("App Name"; Rec."App Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'App name';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Current status';
                    StyleExpr = StatusStyleExpr;
                }
                field("Depends On Entry No."; Rec."Depends On Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Depends on entry';
                }
                field("Wait for Completion"; Rec."Wait for Completion")
                {
                    ApplicationArea = All;
                    ToolTip = 'Wait for completion';
                }
                field("Deployed Date Time"; Rec."Deployed Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Deployment time';
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        UpdateStatusStyle();
    end;

    local procedure UpdateStatusStyle()
    begin
        case Rec.Status of
            Rec.Status::Deployed:
                StatusStyleExpr := 'Favorable';
            Rec.Status::Failed:
                StatusStyleExpr := 'Unfavorable';
            Rec.Status::"Installation In Progress", Rec.Status::"Upload Started",
            Rec.Status::"Upload Completed", Rec.Status::"Waiting for Dependencies":
                StatusStyleExpr := 'Ambiguous';
            else
                StatusStyleExpr := 'Standard';
        end;
    end;

    var
        StatusStyleExpr: Text;
}

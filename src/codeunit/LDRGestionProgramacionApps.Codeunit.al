codeunit 50001 "App Deployment Management"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ProcessScheduledDeployments();
        CheckPendingOperations();
    end;

    var
        DeploymentStartedMsg: Label 'Deployment of %1 has started.', Comment = '%1 = App File Name';
        DeploymentScheduledMsg: Label 'Found %1 app(s) scheduled for deployment.', Comment = '%1 = Number of apps';

    procedure ProcessScheduledDeployments()
    var
        AppDeploymentStaging: Record "App Deployment Staging";
        ProcessedCount: Integer;
    begin
        // Process pending deployments that can be deployed (dependencies met)
        AppDeploymentStaging.SetRange(Status, AppDeploymentStaging.Status::Pending);
        AppDeploymentStaging.SetFilter("Scheduled Date", '<=%1', Today);
        AppDeploymentStaging.SetFilter("Scheduled Time", '<=%1', Time);

        if AppDeploymentStaging.FindSet() then begin
            repeat
                // Check if dependencies are met
                if AppDeploymentStaging.CanBeDeployed() then begin
                    DeployApp(AppDeploymentStaging);
                    ProcessedCount += 1;
                end else
                    // Mark as waiting for dependencies
                    if AppDeploymentStaging.Status = AppDeploymentStaging.Status::Pending then begin
                        AppDeploymentStaging.Status := AppDeploymentStaging.Status::"Waiting for Dependencies";
                        AppDeploymentStaging.Modify(true);
                    end;
            until AppDeploymentStaging.Next() = 0;

            if ProcessedCount > 0 then
                Message(DeploymentScheduledMsg, ProcessedCount);
        end;

        // Also check apps waiting for dependencies
        ProcessWaitingApps();
    end;

    local procedure ProcessWaitingApps()
    var
        AppDeploymentStaging: Record "App Deployment Staging";
    begin
        AppDeploymentStaging.SetRange(Status, AppDeploymentStaging.Status::"Waiting for Dependencies");

        if AppDeploymentStaging.FindSet() then
            repeat
                if AppDeploymentStaging.CanBeDeployed() then
                    DeployApp(AppDeploymentStaging);
            until AppDeploymentStaging.Next() = 0;
    end;

    procedure CheckPendingOperations()
    var
        AppDeploymentStaging: Record "App Deployment Staging";
    begin
        // Check if uploaded apps are now installed
        AppDeploymentStaging.SetFilter(Status, '%1|%2|%3',
            AppDeploymentStaging.Status::"Upload Started",
            AppDeploymentStaging.Status::"Upload Completed",
            AppDeploymentStaging.Status::"Installation In Progress");

        if AppDeploymentStaging.FindSet() then
            repeat
                CheckIfAppIsInstalled(AppDeploymentStaging);
            until AppDeploymentStaging.Next() = 0;
    end;

    local procedure CheckIfAppIsInstalled(var AppDeploymentStaging: Record "App Deployment Staging")
    var
        NavAppInstalledApp: Record "NAV App Installed App";
        MinutesElapsed: Integer;
        AppNameToFind: Text;
    begin
        MinutesElapsed := Round((CurrentDateTime - AppDeploymentStaging."Last Status Check") / 60000, 1);

        // Extract app name from filename (remove .app extension)
        AppNameToFind := AppDeploymentStaging."App Name";
        if AppNameToFind.EndsWith('.app') then
            AppNameToFind := CopyStr(AppNameToFind, 1, StrLen(AppNameToFind) - 4);

        // Try to find the installed app by name
        NavAppInstalledApp.SetFilter(Name, '@*' + AppNameToFind + '*');
        if NavAppInstalledApp.FindFirst() then begin
            // App is installed! Mark as deployed
            AppDeploymentStaging.Status := AppDeploymentStaging.Status::Deployed;
            AppDeploymentStaging."Deployed Date Time" := CurrentDateTime;
            AppDeploymentStaging."App Name" := CopyStr(NavAppInstalledApp.Name, 1, MaxStrLen(AppDeploymentStaging."App Name"));
            AppDeploymentStaging."App Publisher" := CopyStr(NavAppInstalledApp.Publisher, 1, MaxStrLen(AppDeploymentStaging."App Publisher"));
            AppDeploymentStaging."App Version" := GetVersionString(
                NavAppInstalledApp."Version Major",
                NavAppInstalledApp."Version Minor",
                NavAppInstalledApp."Version Build",
                NavAppInstalledApp."Version Revision");
            AppDeploymentStaging.Modify(true);
            Commit();
            SendEmailNotification(AppDeploymentStaging);
            exit;
        end;

        // Update status based on time
        if MinutesElapsed >= 1 then begin
            if AppDeploymentStaging.Status = AppDeploymentStaging.Status::"Upload Started" then begin
                AppDeploymentStaging.Status := AppDeploymentStaging.Status::"Upload Completed";
                AppDeploymentStaging."Last Status Check" := CurrentDateTime;
                AppDeploymentStaging.Modify(true);
            end else if MinutesElapsed >= 2 then begin
                if AppDeploymentStaging.Status = AppDeploymentStaging.Status::"Upload Completed" then begin
                    AppDeploymentStaging.Status := AppDeploymentStaging.Status::"Installation In Progress";
                    AppDeploymentStaging."Last Status Check" := CurrentDateTime;
                    AppDeploymentStaging.Modify(true);
                end;
            end;
        end;

        // If more than 10 minutes and still not found, might have failed
        if MinutesElapsed >= 10 then begin
            AppDeploymentStaging.Status := AppDeploymentStaging.Status::Failed;
            AppDeploymentStaging."Error Message" := 'App not found in installed apps after 10 minutes. Check Extension Management for details.';
            AppDeploymentStaging."Deployed Date Time" := CurrentDateTime;
            AppDeploymentStaging.Modify(true);
            Commit();
            SendEmailNotification(AppDeploymentStaging);
        end;
    end;

    local procedure GetVersionString(VersionMajor: Integer; VersionMinor: Integer; VersionBuild: Integer; VersionRevision: Integer): Text
    begin
        exit(StrSubstNo('%1.%2.%3.%4', VersionMajor, VersionMinor, VersionBuild, VersionRevision));
    end;

    procedure DeployApp(var AppDeploymentStaging: Record "App Deployment Staging")
    begin
        if AppDeploymentStaging.Status <> AppDeploymentStaging.Status::Pending then
            if AppDeploymentStaging.Status <> AppDeploymentStaging.Status::"Waiting for Dependencies" then
                exit;

        AppDeploymentStaging.Status := AppDeploymentStaging.Status::"Upload Started";
        AppDeploymentStaging."Last Status Check" := CurrentDateTime;
        AppDeploymentStaging.Modify(true);
        Commit();

        if not TryDeployApp(AppDeploymentStaging) then begin
            AppDeploymentStaging.Status := AppDeploymentStaging.Status::Failed;
            AppDeploymentStaging."Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(AppDeploymentStaging."Error Message"));
            AppDeploymentStaging."Deployed Date Time" := CurrentDateTime;
            AppDeploymentStaging.Modify(true);
            Commit();
            SendEmailNotification(AppDeploymentStaging);
        end else begin
            AppDeploymentStaging.Status := AppDeploymentStaging.Status::"Upload Completed";
            AppDeploymentStaging."Last Status Check" := CurrentDateTime;
            AppDeploymentStaging.Modify(true);
            Commit();
        end;
    end;

    [TryFunction]
    local procedure TryDeployApp(var AppDeploymentStaging: Record "App Deployment Staging")
    var
        ExtensionManagement: Codeunit "Extension Management";
        FileInStream: InStream;
    begin
        // Get file from BLOB
        AppDeploymentStaging.CalcFields("App File");
        if not AppDeploymentStaging."App File".HasValue then
            Error('App file is missing or has been deleted for security.');

        AppDeploymentStaging.GetAppFile(FileInStream);

        // Upload and Publish the extension
        ExtensionManagement.UploadExtension(FileInStream, GlobalLanguage());

        // SECURITY: Delete the app file immediately after upload
        // This prevents the file from being downloaded later
        Clear(AppDeploymentStaging."App File");
        AppDeploymentStaging."File Deleted After Upload" := true;
        AppDeploymentStaging.Modify(true);
        Commit();

        Message(DeploymentStartedMsg, AppDeploymentStaging."App File Name");
    end;

    procedure SendEmailNotification(var AppDeploymentStaging: Record "App Deployment Staging")
    var
        Recipients: List of [Text];
        Subject: Text;
        Body: Text;
        RecipientText: Text;
    begin
        if not AppDeploymentStaging."Send Email on Completion" then
            exit;

        if AppDeploymentStaging."Email Recipients" = '' then
            exit;

        // Parse recipients
        RecipientText := AppDeploymentStaging."Email Recipients";
        ParseEmailRecipients(RecipientText, Recipients);

        if Recipients.Count = 0 then
            exit;

        // Build email content
        if AppDeploymentStaging.Status = AppDeploymentStaging.Status::Deployed then begin
            Subject := StrSubstNo('✓ App Deployment Successful - %1', AppDeploymentStaging."App File Name");
            Body := BuildSuccessEmailBody(AppDeploymentStaging);
        end else begin
            Subject := StrSubstNo('✗ App Deployment Failed - %1', AppDeploymentStaging."App File Name");
            Body := BuildFailureEmailBody(AppDeploymentStaging);
        end;

        // Send email
        if TrySendEmail(Recipients, Subject, Body) then
            // Log success
            Session.LogMessage('0000APP', 'Email notification sent successfully', Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'AppDeployment');
    end;

    [TryFunction]
    local procedure TrySendEmail(Recipients: List of [Text]; Subject: Text; Body: Text)
    var
        EmailMessage: Codeunit "Email Message";
        Email: Codeunit Email;
    begin
        EmailMessage.Create(Recipients, Subject, Body, true);
        Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
    end;

    local procedure ParseEmailRecipients(RecipientText: Text; var Recipients: List of [Text])
    var
        RecipientArray: List of [Text];
        Recipient: Text;
    begin
        RecipientArray := RecipientText.Split(';');
        foreach Recipient in RecipientArray do begin
            Recipient := DelChr(Recipient, '<>', ' ');
            if Recipient <> '' then
                Recipients.Add(Recipient);
        end;
    end;

    local procedure BuildSuccessEmailBody(var AppDeploymentStaging: Record "App Deployment Staging"): Text
    var
        Body: Text;
    begin
        Body := '<html><body style="font-family: Arial, sans-serif;">';
        Body += '<div style="background-color: #d4edda; padding: 20px; border-left: 4px solid #28a745;">';
        Body += '<h2 style="color: #155724;">✓ App Deployment Successful</h2>';
        Body += '</div>';
        Body += '<div style="padding: 20px;">';
        Body += '<p>The following app has been successfully deployed:</p>';
        Body += '<table style="border-collapse: collapse; width: 100%;">';
        Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>App File:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + AppDeploymentStaging."App File Name" + '</td></tr>';

        if AppDeploymentStaging."App Name" <> '' then
            Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>App Name:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + AppDeploymentStaging."App Name" + '</td></tr>';

        if AppDeploymentStaging."Deployment Group" <> '' then
            Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>Deployment Group:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + AppDeploymentStaging."Deployment Group" + '</td></tr>';

        Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>Scheduled Time:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + Format(AppDeploymentStaging."Scheduled Date") + ' ' + Format(AppDeploymentStaging."Scheduled Time") + '</td></tr>';
        Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>Deployed Time:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + Format(AppDeploymentStaging."Deployed Date Time") + '</td></tr>';
        Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>Created By:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + AppDeploymentStaging."Created By" + '</td></tr>';
        Body += '</table>';
        Body += '<p style="margin-top: 20px;">Please check the Extension Management page in Business Central for more details.</p>';
        Body += '</div>';
        Body += '</body></html>';

        exit(Body);
    end;

    local procedure BuildFailureEmailBody(var AppDeploymentStaging: Record "App Deployment Staging"): Text
    var
        Body: Text;
    begin
        Body := '<html><body style="font-family: Arial, sans-serif;">';
        Body += '<div style="background-color: #f8d7da; padding: 20px; border-left: 4px solid #dc3545;">';
        Body += '<h2 style="color: #721c24;">✗ App Deployment Failed</h2>';
        Body += '</div>';
        Body += '<div style="padding: 20px;">';
        Body += '<p>The following app deployment has failed:</p>';
        Body += '<table style="border-collapse: collapse; width: 100%;">';
        Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>App File:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + AppDeploymentStaging."App File Name" + '</td></tr>';

        if AppDeploymentStaging."App Name" <> '' then
            Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>App Name:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + AppDeploymentStaging."App Name" + '</td></tr>';

        if AppDeploymentStaging."Deployment Group" <> '' then
            Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>Deployment Group:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + AppDeploymentStaging."Deployment Group" + '</td></tr>';

        Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>Scheduled Time:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + Format(AppDeploymentStaging."Scheduled Date") + ' ' + Format(AppDeploymentStaging."Scheduled Time") + '</td></tr>';
        Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>Failed Time:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + Format(AppDeploymentStaging."Deployed Date Time") + '</td></tr>';
        Body += '<tr><td style="padding: 8px; border-bottom: 1px solid #ddd;"><strong>Created By:</strong></td><td style="padding: 8px; border-bottom: 1px solid #ddd;">' + AppDeploymentStaging."Created By" + '</td></tr>';
        Body += '</table>';

        if AppDeploymentStaging."Error Message" <> '' then begin
            Body += '<div style="background-color: #fff3cd; padding: 15px; margin-top: 20px; border-left: 3px solid #ffc107;">';
            Body += '<h3 style="color: #856404;">Error Details:</h3>';
            Body += '<pre style="white-space: pre-wrap; word-wrap: break-word;">' + AppDeploymentStaging."Error Message" + '</pre>';
            Body += '</div>';
        end;

        Body += '<p style="margin-top: 20px;">Please check the Extension Management page in Business Central for more details.</p>';
        Body += '</div>';
        Body += '</body></html>';

        exit(Body);
    end;

    procedure SetupJobQueue()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategory: Record "Job Queue Category";
    begin
        // Create Job Queue Category if it doesn't exist
        if not JobQueueCategory.Get('APPDEPLOY') then begin
            JobQueueCategory.Init();
            JobQueueCategory.Code := 'APPDEPLOY';
            JobQueueCategory.Description := 'App Deployment';
            JobQueueCategory.Insert(true);
        end;

        // Check if job queue entry already exists
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"App Deployment Management");
        if not JobQueueEntry.IsEmpty then begin
            Message('Job Queue Entry already exists. You can modify it from the Job Queue Entries page.');
            exit;
        end;

        // Create new Job Queue Entry
        JobQueueEntry.Init();
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"App Deployment Management";
        JobQueueEntry."Job Queue Category Code" := 'APPDEPLOY';
        JobQueueEntry.Description := 'Process Scheduled App Deployments';
        JobQueueEntry.validate("Run on Mondays", true);
        JobQueueEntry."Run on Tuesdays" := true;
        JobQueueEntry."Run on Wednesdays" := true;
        JobQueueEntry."Run on Thursdays" := true;
        JobQueueEntry."Run on Fridays" := true;
        JobQueueEntry."Run on Saturdays" := true;
        JobQueueEntry."Run on Sundays" := true;
        JobQueueEntry."Starting Time" := 000000T;
        JobQueueEntry."Ending Time" := 235959T;
        JobQueueEntry."No. of Minutes between Runs" := 5; // Check every 5 minutes
        JobQueueEntry."Maximum No. of Attempts to Run" := 3;
        JobQueueEntry."Rerun Delay (sec.)" := 30;
        JobQueueEntry.Status := JobQueueEntry.Status::Ready;
        JobQueueEntry.Insert(true);

        Message('Job Queue Entry created successfully.\Frequency: Every 5 minutes\Status: Ready\n\nIt will automatically:\n- Process scheduled app deployments\n- Check dependencies\n- Send email notifications');
    end;

    procedure OpenExtensionManagement()
    var
        ExtensionManagementPage: Page "Extension Management";
    begin
        ExtensionManagementPage.Run();
    end;

    procedure DeployGroup(GroupCode: Code[20])
    var
        AppDeploymentStaging: Record "App Deployment Staging";
        ProcessedCount: Integer;
    begin
        if GroupCode = '' then
            Error('Group code cannot be empty.');

        // Get all apps in the group
        AppDeploymentStaging.SetRange("Deployment Group", GroupCode);
        AppDeploymentStaging.SetFilter(Status, '%1|%2',
            AppDeploymentStaging.Status::Pending,
            AppDeploymentStaging.Status::"Waiting for Dependencies");
        AppDeploymentStaging.SetCurrentKey("Deployment Group", "Sequence No.");

        if not AppDeploymentStaging.FindSet() then begin
            Message('No pending apps found in group %1.', GroupCode);
            exit;
        end;

        // Mark group deployment as started
        MarkGroupAsStarted(GroupCode);

        // Process apps in sequence
        repeat
            if AppDeploymentStaging.CanBeDeployed() then begin
                DeployApp(AppDeploymentStaging);
                ProcessedCount += 1;

                // If this app requires completion, wait before continuing
                if AppDeploymentStaging."Wait for Completion" then
                    Sleep(5000); // Wait 5 seconds between deployments
            end else begin
                AppDeploymentStaging.Status := AppDeploymentStaging.Status::"Waiting for Dependencies";
                AppDeploymentStaging.Modify(true);
            end;
        until AppDeploymentStaging.Next() = 0;

        if ProcessedCount > 0 then
            Message('Started deploying %1 app(s) from group %2.', ProcessedCount, GroupCode);
    end;

    local procedure MarkGroupAsStarted(GroupCode: Code[20])
    var
        AppDeploymentStaging: Record "App Deployment Staging";
    begin
        AppDeploymentStaging.SetRange("Deployment Group", GroupCode);
        if AppDeploymentStaging.FindSet() then
            repeat
                if not AppDeploymentStaging."Group Deployment Started" then begin
                    AppDeploymentStaging."Group Deployment Started" := true;
                    AppDeploymentStaging.Modify(true);
                end;
            until AppDeploymentStaging.Next() = 0;
    end;
}
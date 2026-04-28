page 50005 "Deployment Group Wizard"
{
    PageType = NavigatePage;
    Caption = 'Asistente de Grupo de Implementación';

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
                    Caption = 'Código del Grupo';
                    ToolTip = 'Enter a unique code for this deployment group';
                }
                field(GroupScheduleDate; GroupScheduleDate)
                {
                    ApplicationArea = All;
                    Caption = 'Fecha Programada';
                    ToolTip = 'Date when the group should be deployed';
                }
                field(GroupScheduleTime; GroupScheduleTime)
                {
                    ApplicationArea = All;
                    Caption = 'Hora Programada';
                    ToolTip = 'Time when the group should be deployed';
                }
                field(EmailRecipients; EmailRecipients)
                {
                    ApplicationArea = All;
                    Caption = 'Destinatarios del Email';
                    ToolTip = 'Direcciones de email separadas por punto y coma';
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
                    Caption = 'Información de Apps';
                    ShowCaption = false;
                    Editable = false;
                    Style = Strong;
                }
                group(UploadInstructions)
                {
                    Caption = 'Instrucciones';
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
                    Caption = 'Revisión';
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
                Caption = 'Subir App';
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
                Caption = 'Eliminar Último';
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
                Caption = 'Siguiente';
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
                Caption = 'Anterior';
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
                Caption = 'Finalizar y Crear Dependencias';
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
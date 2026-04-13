table 50002 "App Deployment Staging"
{
    Caption = 'TablaProgramacionPublicacionApp';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
        }
        field(2; "App File Name"; Text[250])
        {
            Caption = 'App File Name';
        }
        field(3; "App File"; Blob)
        {
            Caption = 'App File';
            Subtype = Bitmap;
        }
        field(4; "Scheduled Date"; Date)
        {
            Caption = 'Scheduled Date';
        }
        field(5; "Scheduled Time"; Time)
        {
            Caption = 'Scheduled Time';
        }
        field(6; Status; Enum "App Deployment Status")
        {
            Caption = 'Status';
            Editable = false;
        }
        field(7; "Deployment Type"; Enum "App Deployment Type")
        {
            Caption = 'Deployment Type';
            InitValue = Publish;
        }
        field(8; "Created Date Time"; DateTime)
        {
            Caption = 'Created Date Time';
            Editable = false;
        }
        field(9; "Deployed Date Time"; DateTime)
        {
            Caption = 'Deployed Date Time';
            Editable = false;
        }
        field(10; "Error Message"; Text[2048])
        {
            Caption = 'Error Message';
            Editable = false;
        }
        field(11; "Created By"; Code[50])
        {
            Caption = 'Created By';
            Editable = false;
        }
        field(12; "Operation ID"; Guid)
        {
            Caption = 'Operation ID';
            Editable = false;
        }
        field(13; "App Name"; Text[250])
        {
            Caption = 'App Name';
            // Editable = false;
        }
        field(14; "App Publisher"; Text[250])
        {
            Caption = 'App Publisher';
            Editable = false;
        }
        field(15; "App Version"; Text[50])
        {
            Caption = 'App Version';
            Editable = false;
        }
        field(16; "Send Email on Completion"; Boolean)
        {
            Caption = 'Send Email on Completion';
            InitValue = true;
        }
        field(17; "Email Recipients"; Text[250])
        {
            Caption = 'Email Recipients';
            ToolTip = 'Semicolon-separated email addresses';
        }
        field(18; "Last Status Check"; DateTime)
        {
            Caption = 'Last Status Check';
            Editable = false;
        }
        field(19; "Deployment Group"; Code[20])
        {
            Caption = 'Deployment Group';
            ToolTip = 'Group multiple apps together for sequential deployment';
        }
        field(20; "Sequence No."; Integer)
        {
            Caption = 'Sequence No.';
            ToolTip = 'Defines the order of deployment within a group (1, 2, 3...)';
            MinValue = 1;

            trigger OnValidate()
            begin
                if "Deployment Group" = '' then
                    Error('Please specify a Deployment Group before setting sequence number.');
            end;
        }
        field(21; "Wait for Completion"; Boolean)
        {
            Caption = 'Wait for Completion';
            InitValue = true;
            ToolTip = 'If true, next app in sequence will wait for this app to complete deployment';
        }
        field(22; "Depends On Entry No."; Integer)
        {
            Caption = 'Depends On Entry No.';
            ToolTip = 'Entry number of the app that must be deployed before this one';
            TableRelation = "App Deployment Staging"."Entry No." where("Deployment Group" = field("Deployment Group"));

            trigger OnValidate()
            var
                DependentApp: Record "App Deployment Staging";
            begin
                if "Depends On Entry No." = 0 then
                    exit;

                if "Depends On Entry No." = "Entry No." then
                    Error('An app cannot depend on itself.');

                if not DependentApp.Get("Depends On Entry No.") then
                    Error('Dependent app entry %1 does not exist.', "Depends On Entry No.");

                if DependentApp."Deployment Group" <> "Deployment Group" then
                    Error('Dependent app must be in the same deployment group.');

                CheckCircularDependency();
            end;
        }
        field(23; "Group Deployment Started"; Boolean)
        {
            Caption = 'Group Deployment Started';
            Editable = false;
        }
        field(24; "File Deleted After Upload"; Boolean)
        {
            Caption = 'File Deleted After Upload';
            Editable = false;
            ToolTip = 'Indicates if the app file was deleted for security after upload';
        }
        field(25; "File Hash"; Text[100])
        {
            Caption = 'File Hash';
            Editable = false;
            ToolTip = 'SHA256 hash of the uploaded file for verification';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Schedule; "Scheduled Date", "Scheduled Time", Status)
        {
        }
        key(OperationID; "Operation ID")
        {
        }
        key(GroupSequence; "Deployment Group", "Sequence No.")
        {
        }
    }

    trigger OnInsert()
    var
        AppDeployment: Record "App Deployment Staging";
    begin
        if AppDeployment.FindLast() then;
        Rec."Entry No." += AppDeployment."Entry No." + 1;

        "Created Date Time" := CurrentDateTime;
        "Created By" := CopyStr(UserId, 1, MaxStrLen("Created By"));
        Status := Status::Pending;
    end;

    trigger OnDelete()
    var
        DependentApps: Record "App Deployment Staging";
    begin
        // Check if any other apps depend on this one
        DependentApps.SetRange("Depends On Entry No.", "Entry No.");
        if not DependentApps.IsEmpty() then
            Error('Cannot delete this entry. Other apps depend on it. Remove dependencies first.');
    end;

    procedure SetAppFile(FileInStream: InStream; FileName: Text)
    var
        OutStream: OutStream;
        TempInStream: InStream;
    begin
        // Store file in BLOB (will be deleted after upload for security)
        "App File".CreateOutStream(OutStream);
        CopyStream(OutStream, FileInStream);
        "App File Name" := CopyStr(FileName, 1, MaxStrLen("App File Name"));

        // Calculate file hash for verification
        CalcFields("App File");
        "App File".CreateInStream(TempInStream);
        "File Hash" := CalculateFileHash(TempInStream);
        "File Deleted After Upload" := false;
    end;

    procedure GetAppFile(var FileInStream: InStream)
    begin
        CalcFields("App File");
        if not "App File".HasValue then
            Error('App file has been deleted for security. Please upload the file again if redeployment is needed.');
        "App File".CreateInStream(FileInStream);
    end;

    local procedure CalculateFileHash(FileInStream: InStream): Text[100]
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512;
    begin
        // Calculate SHA256 hash of the file
        exit(CopyStr(CryptographyManagement.GenerateHash(FileInStream, HashAlgorithmType::SHA256), 1, 100));
    end;

    procedure CheckCircularDependency()
    var
        TempCheckedEntries: Record "App Deployment Staging" temporary;
    begin
        CheckCircularDependencyRecursive("Entry No.", TempCheckedEntries);
    end;

    local procedure CheckCircularDependencyRecursive(EntryNo: Integer; var TempCheckedEntries: Record "App Deployment Staging" temporary)
    var
        AppDeployment: Record "App Deployment Staging";
    begin
        if TempCheckedEntries.Get(EntryNo) then
            Error('Circular dependency detected. This would create an infinite loop.');

        TempCheckedEntries."Entry No." := EntryNo;
        TempCheckedEntries.Insert();

        if AppDeployment.Get(EntryNo) then
            if AppDeployment."Depends On Entry No." <> 0 then
                CheckCircularDependencyRecursive(AppDeployment."Depends On Entry No.", TempCheckedEntries);
    end;

    procedure CanBeDeployed(): Boolean
    var
        DependentApp: Record "App Deployment Staging";
    begin
        // Check if this app can be deployed based on dependencies
        if "Depends On Entry No." = 0 then
            exit(true);

        if not DependentApp.Get("Depends On Entry No.") then
            exit(true);

        // If dependency must complete, check if it's deployed
        if DependentApp."Wait for Completion" then
            exit(DependentApp.Status = DependentApp.Status::Deployed);

        // If dependency doesn't need to complete, check if it at least started
        exit(DependentApp.Status <> DependentApp.Status::Pending);
    end;
}
page 50019 "DET Data Editor Log"
{
    ApplicationArea = All;
    Caption = 'Data Editor Log';
    PageType = List;
    SourceTable = "DET Data Editor Log";
    UsageCategory = Lists;
    ModifyAllowed = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    SourceTableView = sorting("Entry No.") order(descending);

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    Caption = 'Nº Mov.';
                    ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
                }
                field("Record Id"; Format(Rec."Record Id"))
                {
                    Caption = 'Record Id';
                    ToolTip = 'Specifies the value of the Record Id field.', Comment = '%';
                }
                field("Table No."; Rec."Table No.")
                {
                    Caption = 'Nº Tabla';
                    ToolTip = 'Specifies the value of the Table No. field.', Comment = '%';
                }
                field("Table Name"; Rec."Table Name")
                {
                    Caption = 'Nombre Tabla';
                    ToolTip = 'Specifies the value of the Table Name field.', Comment = '%';
                }
                field("Field No."; Rec."Field No.")
                {
                    Caption = 'Nº Campo';
                    ToolTip = 'Specifies the value of the Field No. field.', Comment = '%';
                }
                field("Field Name"; Rec."Field Name")
                {
                    Caption = 'Nombre del campo';
                    ToolTip = 'Specifies the value of the Field Name field.', Comment = '%';
                }
                field("Action Type"; Rec."Action Type")
                {
                    Caption = 'Tipo de acción';
                    ToolTip = 'Specifies the value of the Action Type field.', Comment = '%';
                }
                field("Old Value"; Rec."Old Value")
                {
                    Caption = 'Valor antiguo';
                    ToolTip = 'Specifies the value of the Old Value field.', Comment = '%';
                }
                field("New Value"; Rec."New Value")
                {
                    Caption = 'Valor nuevo';
                    ToolTip = 'Specifies the value of the New Value field.', Comment = '%';
                }
                field("With Validation"; Rec."With Validation")
                {
                    Caption = 'Con validación';
                    ToolTip = 'Specifies the value of the With Validation field.', Comment = '%';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    Caption = 'Fecha Creación';
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.', Comment = '%';
                }
                field(SystemCreatedBy; Rec.GetUserName())
                {
                    Caption = 'Creado por:';
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.', Comment = '%';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(ShowOldValue_promoted; ShowOldValue)
            {

            }
            actionref(ShowNewValue_promoted; ShowNewValue)
            {

            }
        }
        area(Processing)
        {
            action(ShowOldValue)
            {
                ApplicationArea = All;
                Caption = 'Ver Valor Antiguo';
                ToolTip = 'Show Old Value';
                Image = ShowList;
                trigger OnAction()
                begin
                    Message(Rec.GetBLOBDataAsTxt(Rec.FieldNo("Old Value BLOB"), TextEncoding::UTF8));
                end;
            }
            action(ShowNewValue)
            {
                ApplicationArea = All;
                Caption = 'Ver Valor Nuevo';
                ToolTip = 'Show New Value';
                Image = ShowList;
                trigger OnAction()
                begin
                    Message(Rec.GetBLOBDataAsTxt(Rec.FieldNo("New Value BLOB"), TextEncoding::UTF8));
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        if Rec.FindFirst() then; // For some reason, the page shows the last record when we use descending sorting. This is a hotfix.
    end;
}
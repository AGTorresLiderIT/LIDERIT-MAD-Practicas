table 50006 "Commission Process Log_LDR"
{
    // TF0023 RF-2.1: one line per salesperson processed by the automatic settlement. All the lines of one run
    // share the same "Run ID".
    Caption = 'Commission Process Log', Comment = 'ESP="Registro del proceso de comisiones"';
    DataClassification = CustomerContent;
    DrillDownPageId = "Commission Process Log_LDR";
    LookupPageId = "Commission Process Log_LDR";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.', Comment = 'ESP="Nº mov."';
            ToolTip = 'Specifies the number of the log entry.', Comment = 'ESP="Especifica el número de la línea del registro."';
        }
        field(2; "Run ID"; Guid)
        {
            Caption = 'Run ID', Comment = 'ESP="Id. ejecución"';
            ToolTip = 'Specifies the run of the automatic settlement. All the lines of the same run have the same value.', Comment = 'ESP="Especifica la ejecución de la liquidación automática. Todas las líneas de una misma ejecución tienen el mismo valor."';
        }
        field(3; "Start Date-Time"; DateTime)
        {
            Caption = 'Start Date-Time', Comment = 'ESP="Fecha-hora inicio"';
            ToolTip = 'Specifies when the run started.', Comment = 'ESP="Especifica cuándo empezó la ejecución."';
        }
        field(4; "End Date-Time"; DateTime)
        {
            Caption = 'End Date-Time', Comment = 'ESP="Fecha-hora fin"';
            ToolTip = 'Specifies when the salesperson was processed.', Comment = 'ESP="Especifica cuándo terminó el proceso del vendedor."';
        }
        field(5; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code', Comment = 'ESP="Cód. vendedor"';
            TableRelation = "Salesperson/Purchaser";
            ToolTip = 'Specifies the salesperson processed. It is blank when there were no pending commissions.', Comment = 'ESP="Especifica el vendedor procesado. Está en blanco cuando no había comisiones pendientes."';
        }
        field(6; Status; Enum "Commission Process Status_LDR")
        {
            Caption = 'Status', Comment = 'ESP="Estado"';
            ToolTip = 'Specifies whether the salesperson was settled correctly, with a warning or with an error.', Comment = 'ESP="Especifica si el vendedor se liquidó correctamente, con aviso o con error."';
        }
        field(7; "Settlement No."; Code[20])
        {
            Caption = 'Settlement No.', Comment = 'ESP="Nº liquidación"';
            TableRelation = "Comm. Settlement_LDR";
            ToolTip = 'Specifies the settlement created, if any.', Comment = 'ESP="Especifica la liquidación creada, si la hay."';
        }
        field(8; Message; Text[250])
        {
            Caption = 'Message', Comment = 'ESP="Mensaje"';
            ToolTip = 'Specifies the warning or the error text.', Comment = 'ESP="Especifica el texto del aviso o del error."';
        }
        field(9; "User ID"; Code[50])
        {
            Caption = 'User ID', Comment = 'ESP="Id. usuario"';
            DataClassification = EndUserIdentifiableInformation;
            ToolTip = 'Specifies the user that ran the process (the user of the job queue entry).', Comment = 'ESP="Especifica el usuario que ejecutó el proceso (el usuario de la entrada de la cola)."';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}

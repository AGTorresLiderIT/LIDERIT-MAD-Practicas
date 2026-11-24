table 50004 "Commission Import Error_LDR"
{
    // TF0022 RF-3.2: rows of the Excel file that could not be imported. Temporary: it only lives while the
    // import result is shown.
    Caption = 'Commission Import Error', Comment = 'ESP="Error de importación de comisiones"';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Row No."; Integer)
        {
            Caption = 'Row No.', Comment = 'ESP="Nº fila"';
            ToolTip = 'Specifies the row of the Excel file.', Comment = 'ESP="Especifica la fila del fichero Excel."';
        }
        field(2; "Row Text"; Text[250])
        {
            Caption = 'Row Text', Comment = 'ESP="Texto de la fila"';
            ToolTip = 'Specifies the values of the row as they were read from the file.', Comment = 'ESP="Especifica los valores de la fila tal como se han leído del fichero."';
        }
        field(3; Reason; Text[250])
        {
            Caption = 'Reason', Comment = 'ESP="Motivo"';
            ToolTip = 'Specifies why the row was not imported.', Comment = 'ESP="Especifica por qué no se ha importado la fila."';
        }
    }
    keys
    {
        key(PK; "Row No.")
        {
            Clustered = true;
        }
    }
}

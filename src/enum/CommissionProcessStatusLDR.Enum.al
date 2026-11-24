enum 50001 "Commission Process Status_LDR"
{
    // TF0023 RF-2.1: result of the automatic settlement for one salesperson.
    Caption = 'Commission Process Status', Comment = 'ESP="Estado del proceso de comisiones"';
    Extensible = false;

    value(0; Success)
    {
        Caption = 'Success', Comment = 'ESP="Correcto"';
    }
    value(1; Warning)
    {
        Caption = 'Warning', Comment = 'ESP="Aviso"';
    }
    value(2; Error)
    {
        Caption = 'Error', Comment = 'ESP="Error"';
    }
}

pageextension 50109 extPurchasePage extends "Purchases & PAyables Setup"
{
    layout
    {
        addlast(General)
        {
            field("Días pago por empresa"; Rec."Días pago por empresa")
            {
                ApplicationArea = All;
                Caption = 'Días pago por empresa';
                trigger OnValidate()
                var
                    tActivado: Label 'Activado: Los proveedores se crearán con los códigos de pago en blanco.';
                    tDesactivado: Label 'Desactivado: Los proveedores usarán la configuración estandar';

                begin
                    if (Rec."Días pago por empresa") then
                        Message(tActivado)
                    else
                        Message(tDesactivado);
                end;
            }
        }
    }
}

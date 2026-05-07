tableextension 50350 LDRCOBCORUserSetupExt extends "User Setup"
{
    fields
    {
        field(50200; COBCORReopenPurchaseOrder; Boolean)
        {
            Caption = 'Allow Reopen Purchase Order', Comment = 'ESP="Permitir Reabrir Pedido de Compra"';
        }
        field(50201; COBCORPostCredMemWithoutApplTo; Boolean)
        {
            Caption = 'Post Cred Mem Without Appl To', Comment = 'ESP="Nota de abono sin Liquidación"';
        }
        field(50202; COBCORPostPaymentsWithoutApplTo; Boolean)
        {
            Caption = 'Post Payments Without Appl To', Comment = 'ESP="Permitir Pagos sin Liquidación"';
        }
        field(50203; COBCORPostReceivablesWithoutApplTo; Boolean)
        {
            Caption = 'Post Receivables Without Appl To', Comment = 'ESP="Permitir Cobros sin Liquidación"';
        }
        field(50204; COBCORIsCloudAdmin; Boolean)
        {
            Caption = 'Cloud Administrator', Comment = 'ESP="Administrador Nube"';
        }
        field(50205; COBCORIsLocalCloudAdmin; Boolean)
        {
            Caption = 'Cloud Local', Comment = 'ESP="Administrador Local Nube"';
        }
        field(50206; COBCORIsAdminCore; Boolean)
        {
            Caption = 'Core Admin', Comment = 'ESP="Administrador Core"';
        }
        field(50207; COBCORDisableReportingWarning; Boolean)
        {
            Caption = 'Disable Reporting Warning', Comment = 'ESP="Desactivar aviso fecha reporting"';
        }
        field(50208; COBCORDisableInternalDocWarning; Boolean)
        {
            Caption = 'Disable Internal Doc Warning', Comment = 'ESP="Desactivar mensaje Comprobante"';
        }
        field(50209; COBCORAllowPurchInvWhithoutOrd; Boolean)
        {
            Caption = 'Allow Purch Inv Whithout Ord', Comment = 'ESP="Permitir Factura Compra sin Pedido"';
        }
        field(50210; COBCORValidationLog; Boolean)
        {
            Caption = 'Validation Log Active', Comment = 'ESP="Activar Log de Validación"';
        }
    }
}
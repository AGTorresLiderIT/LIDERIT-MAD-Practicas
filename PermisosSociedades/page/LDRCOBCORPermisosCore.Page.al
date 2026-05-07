page 50357 COBCORPermisosCore
{
    ApplicationArea = All;
    Caption = 'Core Permission Configuration', Comment = 'ESP="Conf. Permisos Core"';
    PageType = Card;
    SourceTable = COBCORWizUserConfigurationData;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group("ID Usuario")
            {
                field(gUserID; gUserID)
                {
                    ApplicationArea = All;
                    Caption = 'User ID', Comment = 'ESP="ID Usuario"';
                    Editable = false;
                }
                field(gName; gName)
                {
                    ApplicationArea = All;
                    Caption = 'Full Name', Comment = 'ESP="Nombre Completo"';
                    Editable = false;
                }
                field(gEmail; gEmail)
                {
                    ApplicationArea = All;
                    Caption = 'Email', Comment = 'ESP="Correo Electrónico"';
                    Editable = false;
                }
                field(gCountry; gCountry)
                {
                    ApplicationArea = All;
                    Caption = 'Country', Comment = 'ESP="País"';
                    Editable = false;
                }
            }

            repeater(General)
            {
                Visible = iswizard;
                field(COBCORCompanyName; Rec.COBCORCompanyName)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field.', Comment = 'ESP="Nombre Empresa"';
                    Editable = false;
                }
            }

            group("Permisos gestionados por usuarios")
            {
                Caption = 'Company parameters', Comment = 'ESP="Permisos gestionados por usuarios"';
                Visible = UserConfExist;

                group("Periodos contables")
                {
                    Caption = 'Accounting periods', Comment = 'ESP="Periodos contables"';
                    field(COBCORAllowPostingFrom; RecUserSetup."Allow Posting From")
                    {
                        ApplicationArea = All;
                        Caption = 'Allow Posting From', Comment = 'ESP="Permitir registro desde:"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                    field(COBCORAllowPostingTo; RecUserSetup."Allow Posting To")
                    {
                        ApplicationArea = All;
                        Caption = 'Allow Posting To', Comment = 'ESP="Permitir registro hasta:"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                }
                group("Pedidos")
                {
                    Caption = 'Orders', Comment = 'ESP="Pedidos"';

                    field(COBCORReopenPurchaseOrder; RecUserSetup.COBCORReopenPurchaseOrder)
                    {
                        ApplicationArea = All;
                        Caption = 'Allow Reopen Purchase Order', Comment = 'ESP="Permitir Reabrir Pedido de Compra"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                }
                group("Facturas/Abonos")
                {
                    Caption = 'Purchases/Credit Memo', Comment = 'ESP="Facturas/Abonos"';

                    field(COBCORPostCredMemWithoutApplTo; RecUserSetup.COBCORPostCredMemWithoutApplTo)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Cred Mem Without Appl To', Comment = 'ESP="Nota de abono sin Liquidación"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                }
                group("Tesorería")
                {
                    Caption = 'Treasury', Comment = 'ESP="Tesorería"';

                    field(COBCORPostPaymentsWithoutApplTo; RecUserSetup.COBCORPostPaymentsWithoutApplTo)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Payments Without Appl To', Comment = 'ESP="Permitir Pagos sin Liquidación"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }

                    field(COBCORPostReceivablesWithoutApplTo; RecUserSetup.COBCORPostReceivablesWithoutApplTo)
                    {
                        ApplicationArea = All;
                        Caption = 'Post Receivables Without Appl To', Comment = 'ESP="Permitir Cobros sin Liquidación"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                }
                group("Aprobaciones")
                {
                    Caption = 'Approvals', Comment = 'ESP="Aprobaciones"';
                }
                group("Presupuestos")
                {
                    Caption = 'budgets', Comment = 'ESP="Presupuestos"';
                }
                group("Liquidez")
                {
                    Caption = 'Liquidity', Comment = 'ESP="Liquidez"';
                }
                group("Financiación")
                {
                    Caption = 'Financing', Comment = 'ESP="Financiación"';
                }
                group("Contabilidad")
                {
                    Caption = 'Accounting', Comment = 'ESP="Contabilidad"';
                }
                group("Nube")
                {
                    Caption = 'Cloud', Comment = 'ESP="Nube"';

                    field(COBCORIsCloudAdmin; RecUserSetup.COBCORIsCloudAdmin)
                    {
                        ApplicationArea = All;
                        Caption = 'Cloud Administrator', Comment = 'ESP="Administrador Nube"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                    field(COBCORIsLocalCloudAdmin; RecUserSetup.COBCORIsLocalCloudAdmin)
                    {
                        ApplicationArea = All;
                        Caption = 'Cloud Local', Comment = 'ESP="Administrador Local Nube"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                    field(COBCORIsAdminCore; RecUserSetup.COBCORIsAdminCore)
                    {
                        ApplicationArea = All;
                        Caption = 'Core Admin', Comment = 'ESP="Administrador Core"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                }
                group("Otros valores de configuración")
                {
                    Caption = 'Other setup values', Comment = 'ESP="Otros valores de configuración"';

                    field(COBCORDisableReportingWarning; RecUserSetup.COBCORDisableReportingWarning)
                    {
                        ApplicationArea = All;
                        Caption = 'Disable Reporting Warning', Comment = 'ESP="Desactivar aviso fecha reporting"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                    field(COBCORDisableInternalDocWarning; RecUserSetup.COBCORDisableInternalDocWarning)
                    {
                        ApplicationArea = All;
                        Caption = 'Disable Internal Doc Warning', Comment = 'ESP="Desactivar mensaje Comprobante"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                    field(COBCORAllowPurchInvWhithoutOrd; RecUserSetup.COBCORAllowPurchInvWhithoutOrd)
                    {
                        ApplicationArea = All;
                        Caption = 'Allow Purch Inv Whithout Ord', Comment = 'ESP="Permitir Factura Compra sin Pedido"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                    field(COBCORValidationLog; RecUserSetup.COBCORValidationLog)
                    {
                        ApplicationArea = All;
                        Caption = 'Validation Log Active', Comment = 'ESP="Activar Log de Validación"';

                        trigger OnValidate()
                        begin
                            PersistUserSetupChange();
                        end;
                    }
                }
                group("Compliance")
                {
                    Caption = 'Compliance', Comment = 'ESP="Compliance"';
                }
                group("Maestro Proyectos")
                {
                    Caption = 'Project master', Comment = 'ESP="Maestro Proyectos"';
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        ListaUsuarios: Record COBCORWizUserConfigurationList;
    begin
        gUserID := Rec.COBCORUserID;

        if gUserID <> '' then begin
            ListaUsuarios.Reset();
            ListaUsuarios.SetRange(COBCORUserID, gUserID);
            if ListaUsuarios.FindFirst() then begin
                gName := ListaUsuarios.COBCORFullName;
                gEmail := ListaUsuarios.COBCOREmail;
                gCountry := ListaUsuarios.COBCORCountryName;
            end;
        end;

        IsWizard := true;

        if IsWizard then begin
            RecUserSetup.ChangeCompany(Rec.COBCORCompanyName);

            if RecUserSetup.Get(gUserID) then begin
                UserConfExist := true;
            end else begin
                RecUserSetup.Init();
                RecUserSetup."User ID" := gUserID;
                UserConfExist := true;
            end;
        end;
    end;

    local procedure PersistUserSetupChange()
    begin
        RecUserSetup.ChangeCompany(Rec.COBCORCompanyName);

        if not RecUserSetup.Modify(true) then
            RecUserSetup.Insert(true);
    end;

    var
        RecUserSetup: Record "User Setup";
        UserConfExist: Boolean;
        IsWizard: Boolean;
        gUserID: Code[50];
        gName: Text[250];
        gEmail: Text[250];
        gCountry: text[50];
}
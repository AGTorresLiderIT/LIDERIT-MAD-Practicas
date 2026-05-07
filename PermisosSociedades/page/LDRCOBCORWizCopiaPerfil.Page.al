page 50352 COBCORWizCopiaPerfil
{
    ApplicationArea = All;
    Caption = 'Copy profile', Comment = 'ESP="Copia Perfil"';
    PageType = StandardDialog;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(COBCOR_g_txtUsuarioDesde; COBCOR_g_txtUsuarioDesde)
                {
                    ApplicationArea = All;
                    Caption = 'Copy From', Comment = 'ESP="Copiar desde..."';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        l_recWizUserConfigList: Record COBCORWizUserConfigurationList;
                        l_pageWizUserConfigList: Page COBCORWizUserConfigurationList;
                    begin
                        l_recWizUserConfigList.RESET;
                        if COBCOR_g_txtUsuarioHasta <> '' then
                            l_recWizUserConfigList.SetFilter(COBCORUserID, '<>%1', COBCOR_g_txtUsuarioHasta);

                        CLEAR(l_pageWizUserConfigList);
                        l_pageWizUserConfigList.LOOKUPMODE(TRUE);
                        l_pageWizUserConfigList.SETTABLEVIEW(l_recWizUserConfigList);

                        IF l_pageWizUserConfigList.RUNMODAL = ACTION::LookupOK THEN BEGIN
                            l_pageWizUserConfigList.GETRECORD(l_recWizUserConfigList);
                            COBCOR_g_txtUsuarioDesde := l_recWizUserConfigList.COBCORUserID;
                        END;
                    end;
                }

                field(COBCOR_g_txtUsuarioHasta; COBCOR_g_txtUsuarioHasta)
                {
                    ApplicationArea = All;
                    Caption = 'Copy To', Comment = 'ESP="Copiar hasta..."';
                }

                field(COBCOR_g_txtSociedad; COBCOR_g_txtSociedad)
                {
                    ApplicationArea = All;
                    Caption = 'From company', Comment = 'ESP="De la sociedad"';

                }
            }

            group(Info)
            {
                Caption = 'Information', Comment = 'ESP="Información"';

                field(COBCOR_Info; COBCOR_Info)
                {
                    ApplicationArea = All;
                    Editable = false;
                    MultiLine = true;
                    ShowCaption = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(COBCOR_Ejecutar)
            {
                ApplicationArea = All;
                Caption = 'Execute Copy', Comment = 'ESP="Ejecutar copia"';
                Image = Process;

                trigger OnAction()
                begin
                    COBCOR_g_cduWizUserMgt.COBCOR_ExecuteCopy(COBCOR_g_txtUsuarioDesde, COBCOR_g_txtUsuarioHasta, COBCOR_g_txtSociedad);
                    Message('Copia realizada correctamente');
                end;
            }
        }
    }

    procedure SetDestinationUser(p_UserID: text[140])
    begin
        COBCOR_g_txtUsuarioHasta := p_UserID;
    end;

    trigger OnOpenPage()
    begin
        g_recUserSetup.get(UserId);
    end;

    var
        COBCOR_g_txtUsuarioDesde: Text[50];
        COBCOR_g_txtUsuarioHasta: Text[140];
        COBCOR_g_txtSociedad: Text;
        g_recUserSetup: Record "User Setup";
        COBCOR_Info: Label 'Dejar la sociedad en blanco para hacer una copia completa del perfil';
        COBCOR_g_cduWizUserMgt: Codeunit COBCORWizUsersMgt;
}
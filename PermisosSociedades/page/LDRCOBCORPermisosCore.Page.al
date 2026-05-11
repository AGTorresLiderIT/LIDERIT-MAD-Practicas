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
            part(PermisosDinamicos; "COBCOR Permisos Listados")
            {
                ApplicationArea = All;
                Caption = 'Permisos del Usuario', Comment = 'ESP="Permisos del Usuario"';
                Visible = UserConfExist;
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
            UserConfExist := true;
            CurrPage.PermisosDinamicos.Page.cargarPermisos(gUserID);
        end;
    end;

    var
        UserConfExist: Boolean;
        IsWizard: Boolean;
        gUserID: Code[50];
        gName: Text[250];
        gEmail: Text[250];
        gCountry: text[50];
}